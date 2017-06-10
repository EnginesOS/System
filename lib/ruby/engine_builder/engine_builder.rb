require 'rubygems'
require 'git'
require 'fileutils'

#require 'yajl'
require '/opt/engines/lib/ruby/api/system/errors_api.rb'
require '/opt/engines/lib/ruby/exceptions/engine_builder_exception.rb'

class EngineBuilder < ErrorsApi
  require '/opt/engines/lib/ruby/api/system/container_state_files.rb'
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

  require_relative 'builder/container_creation.rb'
  include  ContainerCreation

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

  def error_hash(msg, params = nil)
    {
      level: :error,
      system: 'Engines Builder',
      error_mesg: msg,
      source: caller[1..6],
      error_log: tail_of_build_error_log,
      build_log: tail_of_build_log,
      params: params
    }
  end

  def warning_hash(msg, params = nil)
    {
      level: :warning,
      system: 'Engines Builder',
      error_mesg: msg,
      params: params
    }
  end

  def initialize(params, core_api)
    @core_api = core_api
    @container = nil
    @build_params = params
  end

  def setup_build
    check_build_params(@build_params)
    @build_params[:engine_name].freeze
    @build_params[:image] = @build_params[:engine_name] #.gsub(/[-_]/, '')
    @build_name = File.basename(@build_params[:repository_url]).sub(/\.git$/, '')
    @web_port = SystemConfig.default_webport
    @memory = @build_params[:memory]
    @app_is_persistent = false
    @result_mesg = 'Aborted Due to Errors'
    @first_build = true
    @attached_services = []
    create_templater
    process_supplied_envs(@build_params[:variables])
    @runtime =  ''
    create_build_dir
    setup_log_output
    @rebuild = false
    @data_uid = '11111'
    @data_gid = '11111'
    @build_params[:data_uid] =  @data_uid
    @build_params[:data_gid] = @data_gid
    SystemDebug.debug(SystemDebug.builder, :builder_init, @build_params)
    @service_builder = ServiceBuilder.new(@core_api, @templater, @build_params[:engine_name], @attached_services)
    SystemDebug.debug(SystemDebug.builder, :builder_init__service_builder, @build_params)
    self
  rescue StandardError => e
    #log_exception(e)
    log_build_errors('Engine Build Aborted Due to:' + e.to_s)
    post_failed_build_clean_up
    log_exception(e)
    raise e
  end

  def service_resource(service_name, what)
    @service_builder.service_resource(service_name, what)
  end

  def volumes
    @service_builder.volumes
  end

  def rebuild_managed_container(engine)
    @engine = engine
    @rebuild = true
    log_build_output('Starting Rebuild')
    backup_lastbuild
    setup_rebuild
    build_container
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

  def setup_engine_dirs
    SystemUtils.run_system('/opt/engines/system/scripts/system/create_container_dir.sh ' + @build_params[:engine_name])
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

  def set_locale
    ## STDERR.puts("LANGUAGE " + @build_params[:lang_code].to_s)
    # STDERR.puts("country_code " + @build_params[:country_code].to_s)
    prefs = SystemPreferences.new
    lang =  @build_params[:lang_code]
    lang = prefs.langauge_code if lang.nil?
    country = @build_params[:country_code]
    country = prefs.country_code if country.nil?
    ##  STDERR.puts("LANGUAGE " + lang.to_s)
    #  STDERR.puts("country_code " + country.to_s)
    @blueprint_reader.environments.push(EnvironmentVariable.new('LANGUAGE', lang.to_s + '_' + country.to_s + ':' + lang.to_s))
    @blueprint_reader.environments.push(EnvironmentVariable.new('LANG', lang.to_s + '_' + country.to_s + '.UTF8'))
    @blueprint_reader.environments.push(EnvironmentVariable.new('LC_ALL', lang.to_s + '_' + country.to_s + '.UTF8'))
  end

  def build_container
    SystemDebug.debug(SystemDebug.builder, 'Starting build with params ', @build_params)
    meets_physical_requirements
    process_blueprint
    set_locale
    setup_build_dir
    get_base_image
    setup_engine_dirs
    create_engine_image
    GC::OOB.run
    create_engine_container
    @service_builder.release_orphans
    #  wait_for_engine
    save_build_result
    close_all
    #   SystemStatus.build_complete(@build_params)
    @container
  rescue StandardError => e
    #log_exception(e)
    log_build_errors('Engine Build Aborted Due to:' + e.to_s)
    STDERR.puts(e.backtrace.to_s)
    post_failed_build_clean_up
    log_exception(e)
    raise e
  ensure
    File.delete('/opt/engines/run/system/flags/building_params') if File.exist?('/opt/engines/run/system/flags/building_params')
    close_all
  end

  def backup_lastbuild
    dir = basedir
    backup = dir + '.backup'
    FileUtils.rm_rf(backup) if Dir.exist?(backup)
    FileUtils.mv(dir, backup) if Dir.exist?(dir)
    true
  end

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
    STDERR.puts('GIT GOT ' + g.to_s)
  end

  def download_blueprint
    FileUtils.mkdir_p(basedir)
    get_http_file(@build_params[:repository_url], @build_params[:repository_url].base_name)
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

  def build_from_blue_print
    backup_lastbuild
    get_blueprint_from_repo
    log_build_output('Cloned Blueprint')
    build_container
  rescue StandardError => e
    post_failed_build_clean_up
    log_exception(e)
  end

  def post_failed_build_clean_up
    SystemStatus.build_failed(@build_params)
    return close_all if @rebuild
    # remove containers
    # remove persistent services (if created/new)
    # deregister non persistent services (if created)
    # FIXME: need to re orphan here if using an orphan Well this should happen on the fresh
    # FIXME: don't delete shared service but remove share entry
    SystemDebug.debug(SystemDebug.builder, :Clean_up_of_Failed_build)
    SystemDebug.debug(SystemDebug.builder, "Called From", caller[0..15])
    SystemDebug.debug(SystemDebug.builder, caller.to_s)
    # FIXME: Stop it if started (ie vol builder failure)
    # FIXME: REmove container if created
    unless @build_params[:reinstall].is_a?(TrueClass)
      begin
        if @container.is_a?(ManagedContainer)
          @container.stop_container if @container.is_running?
          @container.destroy_container if @container.has_container?
          @container.delete_image if @container.has_image?
        end
        @service_builder.service_roll_back
        @core_api.delete_engine_and_services(@build_params)
      rescue
        #dont panic if no container
      end
    end

    #    params = {}
    #    params[:engine_name] = @build_name
    #    @core_api.delete_engine(params) # remove engine if created, removes from manged_engines tree (main reason to call)
    @result_mesg = @result_mesg.to_s + ' Roll Back Complete'
    SystemDebug.debug(SystemDebug.builder,'Roll Back Complete')
    close_all
  end

  def setup_rebuild
    log_build_output('Setting up rebuild')
    FileUtils.mkdir_p(basedir)
    blueprint = @core_api.load_blueprint(@engine)
    statefile = basedir + '/blueprint.json'
    f = File.new(statefile, File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.write(blueprint.to_json)
    f.close
  end

  #app_is_persistent
  #used by builder public
  def running_logs()
    return nil unless @container.nil?
    @container.wait_for_startup(4)
    @container.logs_container
  end

  def engine_environment
    @blueprint_reader.environments
  end

  def flag_restart_required(mc)
    restart_reason='Restart to run post install script, as required in blueprint'
    # FixME this should be elsewhere
    restart_flag_file = ContainerStateFiles.restart_flag_file(mc)
    FileUtils.mkdir_p(ContainerStateFiles.container_flag_dir(mc)) unless Dir.exist?(ContainerStateFiles.container_flag_dir(mc))
    f = File.new(restart_flag_file, 'w+')
    f.puts(restart_reason)
    f.close
    File.chmod(0660, restart_flag_file)
    FileUtils.chown(nil, 'containers', restart_flag_file)
  end

  #      throw BuildStandardError.new(e,'setting web port')
  def log_error_mesg(m, o = nil)
    log_build_errors(m.to_s + o.to_s)
    super
  end

  def basedir
    SystemConfig.DeploymentDir + '/' + @build_name.to_s
  end

  private

  def process_supplied_envs(custom_env)
    SystemDebug.debug(SystemDebug.builder, custom_env, custom_env)
    if custom_env.nil?
      @set_environments = {}
      @environments = []
    elsif custom_env.instance_of?(Array)
      @environments = custom_env # happens on rebuild as custom env is saved in env on disk
      # FIXME: need to vet all environment variables
      @set_environments = {}
    else
      custom_env_hash = custom_env
      SystemDebug.debug(SystemDebug.builder, :Merged_custom_env, custom_env_hash)
      @set_environments = custom_env_hash
      @environments = []
    end
    true
  end

  protected

  def log_exception(e)
    STDERR.puts('Build Exception  ' + e.to_s)
    STDERR.puts('Build Exception  ' + e.backtrace.to_s)
    log_build_errors('Engine Build Aborted Due to:' + e.to_s)
    @result_mesg = 'Error.' + e.to_s
    super
  end
end
