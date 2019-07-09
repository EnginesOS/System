require 'rubygems'
require 'fileutils'
require '/opt/engines/lib/ruby/api/system/errors_api.rb'
require '/opt/engines/lib/ruby/exceptions/engine_builder_exception.rb'

class EngineBuilder < ErrorsApi
  require '/opt/engines/lib/ruby/api/system/container_state_files.rb'

  require_relative 'builder/setup_build_dir.rb'
  include BuildDirSetup

  require_relative 'builder/builders.rb'
  include Builders

  require_relative 'builder/save_engine_configuration.rb'
  include SaveEngineConfiguration

  require_relative 'builder/build_report.rb'
  include BuildReport

  require_relative 'builder/build_output.rb'
  include BuildOutput

  require_relative 'builder/check_build_params.rb'
  include CheckBuildParams

  require_relative 'builder/container_creation.rb'
  include  ContainerCreation

  require_relative 'builder/container_guids.rb'
  include ContainerGuids

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
  :build_error,
  :container,
  :cont_user_id

  attr_accessor :app_is_persistent

  class BuildError < StandardError
    attr_reader :parent_exception, :method_name
    def initialize(parent)
      @container = nil
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
    @blueprint = nil
    STDERR.puts('Build Params ' + params.to_s)
  end

  def service_resource(service_name, what)
    @service_builder.service_resource(service_name, what)
  end

  def volumes
    @service_builder.volumes
  end

  def setup_engine_dirs
    SystemUtils.run_system('/opt/engines/system/scripts/system/create_container_dir.sh ' + @build_params[:engine_name])
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
    @blueprint_reader.environments.push(EnvironmentVariable.new({name: 'LANGUAGE',
                                                                value: lang.to_s + '_' + country.to_s + ':' + lang.to_s,
                                                                own_type: 'application'}))
    @blueprint_reader.environments.push(EnvironmentVariable.new({name: 'LANG', 
                                                                value: lang.to_s + '_' + country.to_s + '.UTF8',
                                                                own_type: 'application'}))
    @blueprint_reader.environments.push(EnvironmentVariable.new({name: 'LC_ALL',
                                                                value: lang.to_s + '_' + country.to_s + '.UTF8',
                                                                own_type: 'application'}))
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
    begin
      f.puts(restart_reason)
    ensure
      f.close
    end
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

  def log_exception(e)
    STDERR.puts('Build Exception  ' + e.to_s)
    STDERR.puts('Build Exception  ' + e.backtrace.to_s)
    log_build_errors('Engine Build Aborted Due to:' + e.to_s)
    @result_mesg = 'Error.' + e.to_s
    super
  end

  private

  def process_supplied_envs(custom_env)
   # SystemDebug.debug(SystemDebug.builder, custom_env, custom_env)
    if custom_env.nil?
      @set_environments = {}
      @environments = []
    elsif custom_env.instance_of?(Array)
      @environments = custom_env # happens on rebuild as custom env is saved in env on disk
      # FIXME: need to vet all environment variables
      @set_environments = {}
    else
      custom_env_hash = custom_env
    #  SystemDebug.debug(SystemDebug.builder, :Merged_custom_env, custom_env_hash)
      @set_environments = custom_env_hash
      @environments = []
    end
    true
  end

end
