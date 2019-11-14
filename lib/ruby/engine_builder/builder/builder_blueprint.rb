

module BuilderBluePrint
  def load_blueprint(bp_name = 'blueprint.json')
    log_build_output('Reading Blueprint')
    BlueprintApi.load_blueprint_file("#{basedir}/#{bp_name}")
  end



  def get_blueprint_from_repo
    log_build_output('Backup last build')
    log_build_output('Cloning Blueprint')
    clone_repo
  end

  def perform_inheritance
     BlueprintApi.perform_inheritance(@blueprint)
  end

  def process_blueprint
    log_build_output('Reading Blueprint')
    @blueprint = load_blueprint if @blueprint.nil?
    version = 0
    unless @blueprint.key?(:schema)
      require '/opt/engines/lib/ruby/engine_builder/blueprint_readers/0/versioned_blueprint_reader.rb'
    else
      version =  @blueprint[:schema][:version][:major]
      if version == 0
        version =  @blueprint[:schema][:version][:minor]
      end

      @blueprint =  perform_inheritance

      unless File.exist?("/opt/engines/lib/ruby/engine_builder/blueprint_readers/#{version}/versioned_blueprint_reader.rb")
        raise EngineBuilderException.new(error_hash('Failed to create Managed Container invalid blueprint schema'))
      end
    require "/opt/engines/lib/ruby/engine_builder/blueprint_readers/#{version}/versioned_blueprint_reader.rb"
    end

    log_build_output("Using Blueprint Schema #{version} Inheriting from arent #{@blueprint[:origin]}")

    @blueprint_reader = VersionedBlueprintReader.new(@memento[:engine_name], @blueprint, self)
    @blueprint_reader.process_blueprint
    ev = EnvironmentVariable.new({name: 'Memory',
      value: @memory,
      owner_type: 'system',
      immutable: "true"
    })
    @blueprint_reader.environments.push(ev)
  end

def clone_repo
  if @memento[:repository_url].end_with?('.json')
    BlueprintApi.download_and_save_blueprint(basedir, @memento[:repository_url])
  else
    log_build_output('Clone Blueprint Repository ' + @memento[:repository_url])
    #SystemDebug.debug(SystemDebug.builder, "get_blueprint_from_repo",@memento[:repository_url], @build_name, SystemConfig.DeploymentDir)
    BlueprintApi.clone_repo(@memento[:repository_url], @build_name, :path => SystemConfig.DeploymentDir)
    #    SystemDebug.debug(SystemDebug.builder, 'GIT GOT ' + g.to_s)
  end
end
end
