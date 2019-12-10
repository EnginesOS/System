module Builders
  require_relative '../service_builder/service_builder.rb'
  require_relative 'builder_public.rb'
  require_relative 'builder_blueprint.rb'
  include BuilderBluePrint
  require 'yajl/json_gem'

  require_relative 'engine_scripts_builder.rb'
  include EngineScriptsBuilder

  require_relative 'base_image.rb'
  require_relative 'build_image.rb'
  require_relative 'physical_checks.rb'

  def setup_build
    check_build_params(memento)
    memento.image = memento.container_name
    @build_name =  memento.container_name
    @web_port = SystemConfig.default_webport
    @memory = memento.memory
    @app_is_persistent = false
    @result_mesg = 'Incomplete'
    @first_build = true
    @attached_services = []
    @runtime =  ''
    backup_lastbuild
    setup_log_output
    if @user_params[:reinstall]
      @rebuild = true
      memento.permission_as = memento.container_name
    end
    set_container_guids
    process_supplied_envs(memento.environments)
    self
  rescue StandardError => e
    #log_exception(e)
    log_build_errors("Engine Build Aborted Due to:#{e}")
    post_failed_build_clean_up
    log_exception(e)
    raise e
  end

  def restore_managed_container(engine)
    @engine = engine
    @rebuild = true
    memento.permission_as = engine.container_name
    log_build_output('Starting Restore')
    setup_rebuild
    build_container
    wait_for_start_up
    save_build_result
    close_all
  rescue StandardError => e
    post_failed_build_clean_up
    log_exception(e)
  ensure
    File.delete('/opt/engines/run/system/flags/building_params') if File.exist?('/opt/engines/run/system/flags/building_params')
  end

  def rebuild_managed_container(p)
    @memento  = p
    #@engine = engine
    @rebuild = true
    log_build_output('Starting Rebuild')
    setup_rebuild
    build_container
    wait_for_start_up
    save_build_result
    close_all
  rescue StandardError => e
    log_exception(e)
    post_failed_build_clean_up
  ensure
    File.delete('/opt/engines/run/system/flags/building_params') if File.exist?('/opt/engines/run/system/flags/building_params')
  end

  def build_from_blue_print
    get_blueprint_from_repo
    log_build_output('Cloned Blueprint')
    build_container
    wait_for_start_up
    save_build_result
    close_all
  rescue StandardError => e
    post_failed_build_clean_up
    log_exception(e)
  ensure
    File.delete('/opt/engines/run/system/flags/building_params') if File.exist?('/opt/engines/run/system/flags/building_params')
  end

  #app_is_persistent
  #used by builder public
  def running_logs()
    if @container.nil?
      'not yet'
    else
      wait_for_start_up
      @container.logs_container
    end
  end

  def templater
    @templater ||= Templater.new(builder_public)
  end

  protected

  def builder_public
    @builder_public ||= BuilderPublic.instance
  end

  def service_builder
    @service_builder ||= ServiceBuilder.instance(templater, memento.container_name, @attached_services, basedir)
  end

  def wait_for_start_up(d=25)
    log_build_output('Waiting for start')
    @container.wait_for('start', d)
    log_build_output('Waiting for startup completion')
    @container.wait_for_startup(d)
  rescue NoMethodError
    post_failed_build_clean_up
  end

  def post_failed_build_clean_up
    SystemStatus.build_failed(@user_params)
    begin
      if @container.is_a?(Container::ManagedContainer)
        @container.stop_container if @container.is_running?
        @container.destroy_container if @container.has_container?
        @container.delete_image if @container.has_image?
      end
    rescue NoMethodError
    end
    service_builder.service_roll_back unless @rebuild.is_a?(TrueClass)
    #FIX ME How Deal withthis
    ###@build_params[:rollback]
    core.delete_engine_and_services(@user_params)
    @result_mesg = "#{@result_mesg} Roll Back Complete"
  ensure
    close_all
    event_handler.trigger_install_event(memento.container_name, 'failed')
  end

  def build_container
    SystemDebug.debug(SystemDebug.builder, 'Starting build with params ', memento, @user_params)
    process_blueprint
    meets_physical_requirements
    set_locale
    setup_build_dir
    get_base_image
    setup_engine_dirs
    create_engine_image
    @container = create_engine_container
    service_builder.release_orphans
    @container
  rescue StandardError => e
    log_build_errors("Engine Build Aborted Due to:#{e}")
    log_exception(e)
    post_failed_build_clean_up
  end

  def save_build_result
    log_build_output('Generating Build Report')
    build_report = generate_build_report(templater, @blueprint)
    @container.store.save_build_report(@container.container_name, build_report)
    @result_mesg = 'Build Successful'
    log_build_output('Build Successful')
    FileUtils.copy_file("#{SystemConfig.DeploymentDir}/build.out", "#{@container.store.container_state_dir(@container.container_name)}/build.log")
    FileUtils.copy_file("#{SystemConfig.DeploymentDir}/build.err", "#{@container.store.container_state_dir(@container.container_name)}/build.err")
    true
  end

  def setup_rebuild
    log_build_output('Setting up rebuild')
    create_build_dir
    blue_print = load_existing_blueprint(memento.container_name)
    bpfile = "#{basedir}/blueprint.json"
    f = File.new(bpfile, File::CREAT | File::TRUNC | File::RDWR, 0640)
    begin
      f.write(blue_print.to_json)
    ensure
      f.close
    end
  end

  def load_existing_blueprint(bn)
    blueprint_r = BlueprintApi.new
    blueprint = blueprint_r.load_blueprint(bn)
    raise EnginesException.new(error_hash('failed to load blueprint', blueprint_r.last_error)) unless blueprint.is_a?(Hash)
    blueprint
  end
end
