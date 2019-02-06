class BlueprintApi < ErrorsApi
  require 'yajl'
  require '/opt/engines/lib/ruby/api/system/container_state_files.rb'

  def save_blueprint(blueprint, container)
    # return log_error_mesg('Cannot save incorrect format',blueprint) unless blueprint.is_a?(Hash)
    SystemDebug.debug(SystemDebug.builder, blueprint.class.name)
    state_dir = ContainerStateFiles.container_state_dir(container)
    Dir.mkdir(state_dir) if File.directory?(state_dir) == false
    statefile = state_dir + '/blueprint.json'
    f = File.new(statefile, File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.write(blueprint.to_json)
    f.close
  end

  def self.load_blueprint_file(blueprint_file_name)
    blueprint_file = File.open(blueprint_file_name, 'r')
    parser = Yajl::Parser.new
    json_hash = parser.parse(blueprint_file.read)
    blueprint_file.close
    STDERR.puts('read:' + json_hash.to_s)
    symbolize_keys(json_hash)
    json_hash

  end

  def load_blueprint(container)
    state_dir = ContainerStateFiles.container_state_dir(container)
    raise EnginesException.new(error_hash('No Statedir', container.container_name)) unless File.directory?(state_dir)
    statefile = state_dir + '/blueprint.json'
    raise EnginesException.new(error_hash("No Blueprint File Found", statefile)) unless File.exist?(statefile)
    BlueprintApi.load_blueprint_file(statefile)
  end

  def  self.perform_inheritance_f(blueprint_url)

    BlueprintApi.perform_inheritance(self.download_blueprint(blueprint_url))
  end

  def  self.perform_inheritance(blueprint)
    if blueprint.key?(:software) \
    && blueprint[:software].key?(:base) \
    &&  blueprint[:software][:base].key?(:inherit)
      unless blueprint[:software][:base][:inherit].nil?
        parent = get_blueprint_parent( blueprint[:software][:base][:inherit])
        STDERR.puts('Parent BP ' + parent.to_s + "\n is a " + parent.class.name)
      else
        STDERR.puts('NO Inherietance' + blueprint[:software][:base].to_s)
      end
      inherit = blueprint[:software][:base][:inherit]
      merge_bp_entry(blueprint, parent, :base)
      parent[:software][:base][:inherit] = inherit

      merge_bp_entry(blueprint, parent, :installed_packages)
      merge_bp_entry(blueprint, parent, :file_write_permissions)
      merge_bp_entry(blueprint, parent, :workers)
      merge_bp_entry(blueprint, parent, :replacement_strings)
      merge_bp_entry(blueprint, parent, :system_packages)
      merge_bp_entry(blueprint, parent, :ports)
      merge_bp_entry(blueprint, parent, :variables)
      merge_bp_entry(blueprint, parent, :environment_variables)
      merge_bp_entry(blueprint, parent, :actionators)
      merge_bp_entry(blueprint, parent, :required_modules)
      merge_bp_entry(blueprint, parent, :scripts)
      merge_bp_entry(blueprint, parent, :database_seed_file)
      merge_bp_entry(blueprint, parent, :schedules)
      merge_bp_entry(blueprint, parent, :external_repositories)
      if blueprint[:software].key?(:framework_specific)
        merge_bp_entry(blueprint, parent,[:framework_specific, :apache_htaccess_files])
        merge_bp_entry(blueprint, parent,[:framework_specific, :custom_php_inis])
        merge_bp_entry(blueprint, parent,[:framework_specific, :apache_httpd_configurations])
        merge_bp_entry(blueprint, parent,[:framework_specific, :rake_tasks])
      end

      blueprint[:orig] = blueprint[:software]
      blueprint[:software] = parent[:software]
      STDERR.puts('Merged BP ' + parent.to_s)
    else
      STDERR.puts('NO blueprint' + blueprint.to_s)
    end
    blueprint
  end

  def self.merge_bp_entry(blueprint, dest, key)
   # STDERR.puts('Parent BP ' + blueprint.to_s + "\n is a " + blueprint.class.name)
    STDERR.puts("\n\n\n\n")
    STDERR.puts('key BP ' + key.to_s + " is a " + key.class.name)
    STDERR.puts('dest BP ' + dest.to_s + "\n is a " + dest.class.name)
    STDERR.puts("\n\n\n\n")
    STDERR.puts('key BP ' + key.to_s + " is a " + key.class.name)
    STDERR.puts('dest software[' + key.to_s + ']' + dest[:software].to_s  + "\nis a " +  dest[:software].class.name)
    unless key.is_a?(Array)
      if blueprint[:software].key?(key)
        if blueprint[:software][key].is_a?(Hash)
          if dest[:software][key].nil?
            dest[:software][key] = blueprint[:software][key]
          else
            dest[:software][key].merge!(blueprint[:software][key])
          end
        elsif blueprint[:software][key].is_a?(Array)
          dest[:software][key].concat(blueprint[:software][key])
        else
          dest[:software][key] = blueprint[:software][key]
        end
      end
    else
      # FIXME Assumes only two keys
      dest.merge!(blueprint[:software][key[0]][key[1]])if blueprint[:software][key[0]].key?(key[1])
    end
    dest
  end

  def self.download_blueprint(url)
    d = '/tmp/blueprint.json'
    self.get_http_file(url, d)
    self.load_blueprint_file('/tmp/blueprint.json')
  end

  def self.download_blueprint_parent(parent_url)
    d = '/tmp/parent_blueprint.json'
    self.get_http_file(parent_url, d)

  end

  def self.get_blueprint_parent(parent_url)
    self.download_blueprint_parent(parent_url)
    self.load_blueprint_file('/tmp/parent_blueprint.json')
  end

  def self.download_and_save_blueprint(basedir, repository_url)
    FileUtils.mkdir_p(basedir)
    d = basedir + '/' + File.basename(repository_url)
    self.get_http_file(repository_url, d)
  end

  def self.get_http_file(url, d)
    require 'open-uri'
    download = open(url)
    IO.copy_stream(download, d)
  end

  #  def self.get_blueprint_parent(parent_url)
  #  self.download_blueprint_parent(parent_url)
  #
  #  end

end
