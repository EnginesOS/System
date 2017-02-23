require 'rubygems'
require 'git'
require 'fileutils'
require 'yajl'
require '/opt/engines/lib/ruby/api/system/errors_api.rb'

class EngineBuilder < ErrorsApi

  require_relative 'builder_public.rb'

  require_relative 'docker_file_builder/docker_file_builder.rb'

  require_relative 'config_file_writer.rb'
  require_relative 'service_builder/service_builder.rb'

  require_relative 'builder/setup_build_dir.rb'
  require_relative 'builder/base_image.rb'
  require_relative 'builder/build_image.rb'
  require_relative 'builder/physical_checks.rb'

  require_relative 'builder/configure_services_backup.rb'
  include ConfigureServicesBackup

  require_relative 'builder/save_engine_configuration.rb'
  include SaveEngineConfiguration

  require_relative 'builder/build_report.rb'
  include BuildReport

  require_relative 'builder/build_output.rb'
  include BuildOutput

  require_relative 'builder/engine_scripts_builder.rb'
  include EngineScriptsBuilder

  require_relative 'builder/check_build_params.rb'
  include CheckBuildParams

  require_relative '../templater/templater.rb'

  attr_reader   :templater,
  :repoName,
  :build_name,
  :set_environments,
  :environments,
  :runtime,
  :web_port,
  :blueprint,
  :first_build,
  :memory,
  :result_mesg,
  :build_params,
  :data_uid,
  :data_gid,
  :build_error

  attr_accessor :app_is_persistent
  class BuildError < StandardError
    attr_reader :parent_exception, :method_name
    def initialize(parent)
      @container=nil
      @parent_exception = parent
    end
  end

  def initialize(params, core_api)
    @core_api = core_api
    @container = nil
    @build_params = params
    return log_error_mesg('empty container name', params) if @build_params[:engine_name].nil? || @build_params[:engine_name] == ''
    @build_params[:engine_name].freeze
    @build_name = File.basename(@build_params[:repository_url]).sub(/\.git$/, '')
    @web_port = SystemConfig.default_webport
    @memory = @build_params[:memory]
    @app_is_persistent = false
    @result_mesg = 'Aborted Due to Errors'
    @first_build = true
    @attached_services = []
    return "error" unless create_templater
    return "error" unless process_supplied_envs(params[:variables])
    @runtime =  ''
    return "error" unless create_build_dir
    return "error" unless setup_log_output
    @rebuild = false
    @data_uid = '11111'
    @data_gid = '11111'
    @build_params[:data_uid] =  @data_uid
    @build_params[:data_gid] = @data_gid
    SystemDebug.debug(SystemDebug.builder, :builder_init, params,@build_params)
    @service_builder = ServiceBuilder.new(@core_api, @templater, @build_params[:engine_name],  @attached_services)
    SystemDebug.debug(SystemDebug.builder, :builder_init__service_builder, params,@build_params)
  rescue StandardError => e
    log_exception(e)
  end

  def volumes
    return @service_builder.volumes
  end

  def rebuild_managed_container(engine)
    @engine = engine
    @rebuild = true
    log_build_output('Starting Rebuild')
    return log_error_mesg('Failed to Backup Last build', self) unless backup_lastbuild
    return log_error_mesg('Failed to setup rebuild', self) unless setup_rebuild
    return build_container
  end

  def build_failed(errmesg)
    @build_params[:error_mesg] = errmesg
    SystemStatus.build_failed(@build_params)
    #log_build_errors(errmesg)
    log_build_errors('Engine Build Aborted Due to:' + errmesg.to_s)
    @result_mesg = 'Error.' + errmesg
    post_failed_build_clean_up
  end

  def process_blueprint
    log_build_output('Reading Blueprint')
    @blueprint = load_blueprint
    return post_failed_build_clean_up if @blueprint.nil? || @blueprint == false
    version = 0
    unless @blueprint.key?(:schema)
      require_relative 'blueprint_readers/0/versioned_blueprint_reader.rb'
    else 
      STDERR.puts('BP Schema :' + @blueprint[:schema].to_s + ':' )
      version =  @blueprint[:schema][:version][:major]
        unless File.exist?('blueprint_readers/' + version.to_s + '/versioned_blueprint_reader.rb')
         log_build_errors('Failed to create Managed Container invalid blueprint schema')
         return post_failed_build_clean_up
        end
      require_relative 'blueprint_readers/' + version.to_s + '/versioned_blueprint_reader.rb'
    end
    
    log_build_output('Using Blueprint Schema ' + version.to_s )
    
    @blueprint_reader = VersionedBlueprintReader.new(@build_params[:engine_name], @blueprint, self)
    return post_failed_build_clean_up unless @blueprint_reader.process_blueprint
    true
  rescue Exception => e
    log_build_errors('Failed to create Managed Container Problem with blueprint: ' + e.to_s)
    log_build_errors("dbg " + e.backtrace.to_s)
            return post_failed_build_clean_up
     
  end

  def setup_engine_dirs
    SystemUtils.run_system('/opt/engines/system/scripts/system/create_container_dir.sh ' + @build_params[:engine_name])
  end

  def create_engine_container
    log_build_output('Creating Deploy Image')
    @container = create_managed_container
    unless @container.is_a?(ManagedEngine)
      log_build_errors('Failed to create Managed Container')
      return post_failed_build_clean_up
    end
    @service_builder.create_non_persistent_services(@blueprint_reader.services)
    true
  rescue StandardError => e
    abort_build
  end

  def save_build_result
    @result_mesg = 'Build Successful'
    log_build_output('Build Successful')
    build_report = generate_build_report(@templater, @blueprint)
    @core_api.save_build_report(@container, build_report)
    FileUtils.copy_file(SystemConfig.DeploymentDir + '/build.out',ContainerStateFiles.container_state_dir(@container) + '/build.log')
    FileUtils.copy_file(SystemConfig.DeploymentDir + '/build.err',ContainerStateFiles.container_state_dir(@container) + '/build.err')
    true
  end

  def wait_for_engine
    cnt = 0
    lcnt = 5
    log_build_output('Starting Engine')
    while @container.is_startup_complete? == false && @container.is_running?
      cnt += 1
      if cnt == 120
        log_build_output('') # force EOL to end the ...
        log_build_output('Startup still running')
        break
      end
      if lcnt == 5
        add_to_build_output('.')
        lcnt = 0
      else
        lcnt += 1
      end
      sleep 1
    end
    log_build_output('') # force EOL to end the ...
    if @container.is_running? == false

      log_build_output('Engine Stopped:' + @container.logs_container.to_s)
      @result_mesg = 'Engine Stopped! ' + @container.logs_container.to_s
      return false
    end
    true
    rescue StandardError => e
      log_exception(e)
  end

  def build_container
    SystemDebug.debug(SystemDebug.builder,  ' Starting build with params ',  @build_params)

    return false unless meets_physical_requirements
    return false unless process_blueprint
    return false unless setup_build_dir
    return false unless get_base_image
    return false unless setup_engine_dirs
    return false unless create_engine_image
    return false unless create_engine_container
    @service_builder.release_orphans
    wait_for_engine
    save_build_result
    close_all
    SystemStatus.build_complete(build_params)
    return @container
  rescue StandardError => e
    log_exception(e)
    post_failed_build_clean_up
  ensure
    File.delete('/opt/engines/run/system/flags/building_params') if File.exist?('/opt/engines/run/system/flags/building_params')
    close_all
  end

  def backup_lastbuild
    dir = basedir
    backup = dir + '.backup'
    FileUtils.rm_rf(backup) if Dir.exist?(backup)
    FileUtils.mv(dir, backup) if Dir.exist?(dir)
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def load_blueprint
    log_build_output('Reading Blueprint')
    json_hash = BlueprintApi.load_blueprint_file(basedir + '/blueprint.json')
    return SystemUtils.symbolize_keys(json_hash)
  rescue StandardError => e
    log_exception(e)
  end

  def clone_repo
    log_build_output('Clone Blueprint Repository')
    g = Git.clone(@build_params[:repository_url], @build_name, :path => SystemConfig.DeploymentDir)
  rescue StandardError => e
    log_error_mesg('Problem cloning Git', g)
    log_exception(e)
  end

  def launch_deploy(managed_container)
    log_build_output('Launching Engine')
    r = managed_container.create_container
    return log_error_mesg('Failed to Launch ', @container) if @container.is_a?(EnginesError)
    save_engine_built_configuration(managed_container)
    return r
  rescue StandardError => e
    abort_build
    log_exception(e)
  end

  def get_blueprint_from_repo
    log_build_output('Backup last build')
    return log_error_mesg('Failed to Backup Last build', self) unless backup_lastbuild
    log_build_output('Cloning Blueprint')
    clone_repo
  end

  def build_from_blue_print
    return log_error_mesg('Failed backup last build',self) unless backup_lastbuild
    return log_error_mesg('Failed to Load Blue print',self) unless get_blueprint_from_repo
    log_build_output('Cloned Blueprint')
    build_container
  end

  def post_failed_build_clean_up
    return close_all if @rebuild
    # remove containers
    # remove persistent services (if created/new)
    # deregister non persistent services (if created)
    # FIXME: need to re orphan here if using an orphan Well this should happen on the fresh
    # FIXME: don't delete shared service but remove share entry
    SystemDebug.debug(SystemDebug.builder, :Clean_up_Failed_build)
    SystemDebug.debug(SystemDebug.builder, caller.to_s)
    # FIXME: Stop it if started (ie vol builder failure)
    # FIXME: REmove container if created
    unless @build_params[:reinstall].is_a?(TrueClass)
      if @container.is_a?(ManagedContainer)
        @container.stop_container if @container.is_running?
        @container.destroy_container if @container.has_container?
        @container.delete_image if @container.has_image?
      end

      return log_error_mesg('Failed to remove ' + @service_builder.last_error.to_s ,self) unless @service_builder.service_roll_back
      return log_error_mesg('Failed to remove ' + @core_api.last_error.to_s ,self) unless @core_api.remove_engine(@build_params[:engine_name])
    end

    #    params = {}
    #    params[:engine_name] = @build_name
    #    @core_api.delete_engine(params) # remove engine if created, removes from manged_engines tree (main reason to call)
    @result_mesg = @result_mesg.to_s + ' Roll Back Complete'
    SystemDebug.debug(SystemDebug.builder,'Roll Back Complete')
    close_all
    return false
  end

  def setup_rebuild
    log_build_output('Setting up rebuild')
    FileUtils.mkdir_p(basedir)
    blueprint = @core_api.load_blueprint(@engine)
    statefile = basedir + '/blueprint.json'
    f = File.new(statefile, File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.write(blueprint.to_json)
    f.close
  rescue StandardError => e
    abort_build
    log_exception(e)
  end

  #app_is_persistent
  #used by builder public
  def running_logs()
    return @container.logs_container unless @container.nil?
    return nil
  end

  def create_managed_container
    log_build_output('Creating ManagedEngine')
    @build_params[:web_port] = @web_port
    @build_params[:volumes] = @service_builder.volumes
    @build_params[:image] = @build_params[:engine_name]
    @container = ManagedEngine.new(@build_params, @blueprint_reader, @core_api.container_api)
    @container.save_state # no running.yaml throws a no such container so save so others can use
    log_build_errors('Failed to save blueprint ' + @blueprint.to_s) unless @container.save_blueprint(@blueprint)
    log_build_output('Launching ' + @container.to_s)
    @core_api.init_engine_dirs(@container)
    return log_build_errors('Error Failed to Launch') unless launch_deploy(@container)

    log_build_output('Applying Volume settings and Log Permissions' + @container.to_s)
    return log_build_errors('Error Failed to Apply FS' + @container.to_s) unless @service_builder.run_volume_builder(@container, @web_user)
    flag_restart_required(@container) if @has_post_install == true
    return @container
  rescue StandardError => e
    abort_build
    log_exception(e)
  end

  def engine_environment
    return @blueprint_reader.environments
  end

  def flag_restart_required(mc)
    restart_reason='Restart to run post install script, as required in blueprint'
    # FixME this should be elsewhere
    restart_flag_file = ContainerStateFiles.restart_flag_file(mc)
    FileUtils.mkdir_p(ContainerStateFiles.container_flag_dir(mc)) unless Dir.exist?(ContainerStateFiles.container_flag_dir(mc))
    f = File.new(restart_flag_file,'w+')
    f.puts(restart_reason)
    f.close
    File.chmod(0660,restart_flag_file)
    FileUtils.chown(nil,'containers',restart_flag_file)
  end

  def log_error_mesg(m,o)
    
    log_build_errors(m.to_s + o.to_s)
    super
  end

  def abort_build
    post_failed_build_clean_up
    return true
  end

  def basedir
    SystemConfig.DeploymentDir + '/' + @build_name.to_s
  end

  private

  def process_supplied_envs(custom_env)
    SystemDebug.debug(SystemDebug.builder,  :custom_env, custom_env)
    if custom_env.nil?
      @set_environments = {}
      @environments = []
    elsif custom_env.instance_of?(Array)
      @environments = custom_env # happens on rebuild as custom env is saved in env on disk
      # FIXME: need to vet all environment variables
      @set_environments = {}
    else
      custom_env_hash = custom_env
      SystemDebug.debug(SystemDebug.builder,   :Merged_custom_env, custom_env_hash)
      @set_environments = custom_env_hash
      @environments = []
    end
    return true
  rescue StandardError => e
    log_exception(e)
  end

  protected

  def log_exception(e)
    log_build_errors(e.to_s)
    build_failed(e.to_s)
    super
  end
end
