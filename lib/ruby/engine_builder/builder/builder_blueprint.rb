require 'git'

module BuilderBluePrint
  def load_blueprint(bp_name = 'blueprint.json')
    log_build_output('Reading Blueprint')
    json_hash = BlueprintApi.load_blueprint_file(basedir + '/' + bp_name)
    symbolize_keys(json_hash)
  end

  def clone_repo
    if @build_params[:repository_url].end_with?('.json')
      download_blueprint
    else
      log_build_output('Clone Blueprint Repository ' + @build_params[:repository_url])
      SystemDebug.debug(SystemDebug.builder, "get_blueprint_from_repo",@build_params[:repository_url], @build_name, SystemConfig.DeploymentDir)
      g = Git.clone(@build_params[:repository_url], @build_name, :path => SystemConfig.DeploymentDir)
      SystemDebug.debug(SystemDebug.builder, 'GIT GOT ' + g.to_s)
    end
  end

  def download_blueprint_parent(parent_url)
    d = basedir + '/parent_blueprint.json'
    get_http_file(parent_url, d)
  end

  def  get_blueprint_parent(parent_url)
    download_blueprint_parent(parent_url)
    load_blueprint('parent_blueprint.json')
  end

  def download_blueprint
    FileUtils.mkdir_p(basedir)
    d = basedir + '/' + File.basename(@build_params[:repository_url])
    get_http_file(@build_params[:repository_url], d)
  end

  def get_http_file(url, d)
    require 'open-uri'
    download = open(url)
    IO.copy_stream(download, d)
  end

  def get_blueprint_from_repo
    log_build_output('Backup last build')
    log_build_output('Cloning Blueprint')
    clone_repo
  end

  def perfom_inheritance
    if @blueprint.key?(:software) \
    && @blueprint[:software].key?(:base) \
    &&  @blueprint[:software][:base].key?(:inherit)
      unless @blueprint[:software][:base][:inherit].nil?
        parent = get_blueprint_parent(@blueprint[:software][:base][:inherit])
      end
      inherit = @blueprint[:software][:base] [:inherit]
      merge_bp_entry(parent, :base)
      parent[:software][:base][:inherit]  = inherit

      merge_bp_entry(parent,:installed_packages)
      merge_bp_entry(parent,:file_write_permissions)
      merge_bp_entry(parent,:file_write_permissions)
      merge_bp_entry(parent,:workers)
      merge_bp_entry(parent,:replacement_strings)

      merge_bp_entry(parent,:ports)
      merge_bp_entry(parent,:variables)
      merge_bp_entry(parent,:environment_variables)
      merge_bp_entry(parent,:actionators)
      merge_bp_entry(parent,:required_modules)
      merge_bp_entry(parent,:scripts)
      merge_bp_entry(parent,:database_seed_file)
      merge_bp_entry(parent,:schedules)
      merge_bp_entry(parent,:external_repositories)
      if @blueprint[:software].key?(:framework_specific)
        merge_bp_entry(parent,[:framework_specific, :apache_htaccess_files])
        merge_bp_entry(parent,[:framework_specific, :custom_php_inis])
        merge_bp_entry(parent,[:framework_specific, :apache_httpd_configurations])
      end

      @blueprint[:software] = parent[:software]
    end

  end

  def merge_bp_entry(dest, key)
    unless key.is_a?(Array)
      if @blueprint[:software].key?(key)
        if @blueprint[:software][key].is_a?(Hash)
          dest[:software][key].merge!(@blueprint[:software][key])
        elsif @blueprint[:software][key].is_a?(Array)
          @blueprint[:software][key].concat(dest[:software][key])
          dest[:software][key]  = @blueprint[:software][key]
        else
          dest[:software][key] = @blueprint[:software][key]
        end
      end
    else
      # FIXME Assumes only two keys
      dest.merge!(@blueprint[:software][key[0]][key[1]])if @blueprint[:software][key[0]].key?(key[1])
    end
  end

  def process_blueprint
    log_build_output('Reading Blueprint')
    @blueprint = load_blueprint if @blueprint.nil?
    version = 0
    unless @blueprint.key?(:schema)
      require '/opt/engines/lib/ruby/engine_builder/blueprint_readers/0/versioned_blueprint_reader.rb'
    else
      #   STDERR.puts('BP Schema :' + @blueprint[:schema].to_s + ':' )
      version =  @blueprint[:schema][:version][:major]
      if version == 0
        version =  @blueprint[:schema][:version][:minor]
      end

      perfom_inheritance

      unless File.exist?('/opt/engines/lib/ruby/engine_builder/blueprint_readers/' + version.to_s + '/versioned_blueprint_reader.rb')
        raise EngineBuilderException.new(error_hash('Failed to create Managed Container invalid blueprint schema'))
      end
      require '/opt/engines/lib/ruby/engine_builder/blueprint_readers/' + version.to_s + '/versioned_blueprint_reader.rb'
    end

    log_build_output('Using Blueprint Schema ' + version.to_s + ' ' + @blueprint[:origin].to_s)

    @blueprint_reader = VersionedBlueprintReader.new(@build_params[:engine_name], @blueprint, self)
    @blueprint_reader.process_blueprint
    ev = EnvironmentVariable.new('Memory', @memory, false, true, false, 'Memory', false)
    @blueprint_reader.environments.push(ev)
  end
end
