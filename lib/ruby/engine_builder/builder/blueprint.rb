def load_blueprint
  log_build_output('Reading Blueprint')
  json_hash = BlueprintApi.load_blueprint_file(basedir + '/blueprint.json')
  symbolize_keys(json_hash)
end

def clone_repo
  return download_blueprint if @build_params[:repository_url].end_with?('.json')
  log_build_output('Clone Blueprint Repository ' + @build_params[:repository_url])
  SystemDebug.debug(SystemDebug.builder, "get_blueprint_from_repo",@build_params[:repository_url], @build_name, SystemConfig.DeploymentDir)
  g = Git.clone(@build_params[:repository_url], @build_name, :path => SystemConfig.DeploymentDir)
  SystemDebug.debug(SystemDebug.builder, 'GIT GOT ' + g.to_s)
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
  backup_lastbuild
  log_build_output('Cloning Blueprint')
  clone_repo
end

def process_blueprint
  log_build_output('Reading Blueprint')
  @blueprint = load_blueprint
  version = 0
  unless @blueprint.key?(:schema)
    require_relative 'blueprint_readers/0/versioned_blueprint_reader.rb'
  else
    #   STDERR.puts('BP Schema :' + @blueprint[:schema].to_s + ':' )
    version =  @blueprint[:schema][:version][:major]
    unless File.exist?('/opt/engines/lib/ruby/engine_builder/blueprint_readers/' + version.to_s + '/versioned_blueprint_reader.rb')
      raise EngineBuilderException.new(error_hash('Failed to create Managed Container invalid blueprint schema'))
    end
    require_relative 'blueprint_readers/' + version.to_s + '/versioned_blueprint_reader.rb'
  end

  log_build_output('Using Blueprint Schema ' + version.to_s + ' ' + @blueprint[:origin].to_s)

  @blueprint_reader = VersionedBlueprintReader.new(@build_params[:engine_name], @blueprint, self)
  @blueprint_reader.process_blueprint
  ev = EnvironmentVariable.new('Memory', @memory, false, true, false, 'Memory', false)
  @blueprint_reader.environments.push(ev)
end