require 'git'

module BuilderBluePrint
  def load_blueprint(bp_name = 'blueprint.json')
    log_build_output('Reading Blueprint')
    BlueprintApi.load_blueprint_file(basedir + '/' + bp_name)
  end

  def clone_repo
    if @build_params[:repository_url].end_with?('.json')
      BlueprintApi.download_and_save_blueprint(basedir, @build_params[:repository_url])
    else
      log_build_output('Clone Blueprint Repository ' + @build_params[:repository_url])
      #SystemDebug.debug(SystemDebug.builder, "get_blueprint_from_repo",@build_params[:repository_url], @build_name, SystemConfig.DeploymentDir)
      g = Git.clone(@build_params[:repository_url], @build_name, :path => SystemConfig.DeploymentDir)
      #    SystemDebug.debug(SystemDebug.builder, 'GIT GOT ' + g.to_s)
    end
  end

  def get_blueprint_from_repo
    log_build_output('Backup last build')
    log_build_output('Cloning Blueprint')
    clone_repo
  end

  def perform_inheritance
    bp = BlueprintApi.perform_inheritance(@blueprint)
    STDERR.puts('Parent BP ' + bp.to_s)
    bp
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

      @blueprint =  perform_inheritance

      unless File.exist?('/opt/engines/lib/ruby/engine_builder/blueprint_readers/' + version.to_s + '/versioned_blueprint_reader.rb')
        raise EngineBuilderException.new(error_hash('Failed to create Managed Container invalid blueprint schema'))
      end
      require '/opt/engines/lib/ruby/engine_builder/blueprint_readers/' + version.to_s + '/versioned_blueprint_reader.rb'
    end

    log_build_output('Using Blueprint Schema ' + version.to_s + ' Inheriting from arent ' + @blueprint[:origin].to_s)

    @blueprint_reader = VersionedBlueprintReader.new(@build_params[:engine_name], @blueprint, self)
    @blueprint_reader.process_blueprint
    ev = EnvironmentVariable.new({name: 'Memory',
      value: @memory,
      owner_type: 'system',
      immutable: "true"
    })
    @blueprint_reader.environments.push(ev)
  end
end
