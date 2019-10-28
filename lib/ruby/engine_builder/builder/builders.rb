module Builders
  require_relative '../service_builder/service_builder.rb'
  require_relative 'builder_public.rb'
  require_relative 'builder_blueprint.rb'
  include BuilderBluePrint

  require_relative 'engine_scripts_builder.rb'
  include EngineScriptsBuilder

  require_relative 'base_image.rb'
  require_relative 'build_image.rb'
  require_relative 'physical_checks.rb'
  def setup_build
    check_build_params(@build_params)
    @build_params[:engine_name].freeze
    @build_params[:image] = @build_params[:engine_name]
    @build_name =  @build_params[:engine_name]
    @web_port = SystemConfig.default_webport
    @memory = @build_params[:memory]
    @app_is_persistent = false
    @result_mesg = 'Incomplete'
    @first_build = true
    @attached_services = []
    @runtime =  ''
    backup_lastbuild
    setup_log_output
    if @build_params[:reinstall]
      @rebuild = true
      @build_params[:permission_as] = @build_params[:engine_name]
    end
    set_container_guids
    process_supplied_envs(@build_params[:variables])
    @service_builder ||= ServiceBuilder.new(templater, @build_params[:engine_name], @attached_services, basedir)
    self
  rescue StandardError => e
    #log_exception(e)
    log_build_errors('Engine Build Aborted Due to:' + e.to_s)
    post_failed_build_clean_up
    log_exception(e)
    raise e
  end

  def restore_managed_container(engine)
    @engine = engine
    @rebuild = true
    @build_params[:permission_as] = engine.container_name
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

  def rebuild_managed_container(engine)
    @engine = engine
    @rebuild = true
    @build_params[:permission_as] = engine.container_name
    log_build_output('Starting Rebuild')
    setup_rebuild
    build_container
    wait_for_start_up
    save_build_result
    close_all
  rescue StandardError => e
    post_failed_build_clean_up
    #log_exception(e)
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
    #log_exception(e)
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
    @templater ||= Templater.new(BuilderPublic.new(self))
  end

  protected

 def service_builder 
    @service_builder ||= ServiceBuilder.new(templater, @build_params[:engine_name], @attached_services, basedir)
 end
    
  def wait_for_start_up(d=25)
    log_build_output('Waiting for start')
    @container.wait_for('start', d)
    log_build_output('Waiting for startup completion')
    @container.wait_for_startup(d)
  end

  def post_failed_build_clean_up
    SystemStatus.build_failed(@build_params)
    begin
      if @container.is_a?(Container::ManagedContainer)
        @container.stop_container if @container.is_running?
        @container.destroy_container if @container.has_container?
        @container.delete_image if @container.has_image?
      end
      service_builder.service_roll_back unless @rebuild.is_a?(TrueClass)
      @build_params[:rollback]
      core.delete_engine_and_services(@build_params)
      core.trigger_install_event(@build_params[:engine_name], 'failed')
    rescue
      #dont panic if no container
    end
    @result_mesg = @result_mesg.to_s + ' Roll Back Complete'
  #  SystemDebug.debug(SystemDebug.builder,'Roll Back Complete')
    close_all
  end

  def build_container
    SystemDebug.debug(SystemDebug.builder, 'Starting build with params ', @build_params)
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
    #log_exception(e)
    log_build_errors('Engine Build Aborted Due to:' + e.to_s)
    STDERR.puts(e.backtrace.to_s)
    # post_failed_build_clean_up
   # log_exception(e)
   # raise e
    #  close_all
  end

  def save_build_result
    log_build_output('Generating Build Report')
    build_report = generate_build_report(templater, @blueprint)
    core.save_build_report(@container, build_report)
    @result_mesg = 'Build Successful'
    log_build_output('Build Successful')
    FileUtils.copy_file(SystemConfig.DeploymentDir + '/build.out', ContainerStateFiles.container_state_dir(@container.store_address) + '/build.log')
    FileUtils.copy_file(SystemConfig.DeploymentDir + '/build.err', ContainerStateFiles.container_state_dir(@container.store_address) + '/build.err')
    true
  end


  def setup_rebuild
    log_build_output('Setting up rebuild')
    create_build_dir
    blue_print = @engine.load_blueprint
    statefile = basedir + '/blueprint.json'
    f = File.new(statefile, File::CREAT | File::TRUNC | File::RDWR, 0644)
    begin
      f.write(blue_print.to_json)
    ensure
      f.close
    end
  end

end
