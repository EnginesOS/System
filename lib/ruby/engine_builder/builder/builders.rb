module Builders
  require_relative '../service_builder/service_builder.rb'
 
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
  
  def rebuild_managed_container(engine)
    @engine = engine
    @rebuild = true
    log_build_output('Starting Rebuild')
    backup_lastbuild
    setup_rebuild
    build_container
    save_build_result
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
    @container = create_engine_container
    @service_builder.release_orphans
    #  wait_for_engine
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

  def setup_rebuild
    log_build_output('Setting up rebuild')
    FileUtils.mkdir_p(basedir)
    blueprint = @core_api.load_blueprint(@engine)
    statefile = basedir + '/blueprint.json'
    f = File.new(statefile, File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.write(blueprint.to_json)
    f.close
  end

  def build_from_blue_print
    backup_lastbuild
    get_blueprint_from_repo
    log_build_output('Cloned Blueprint')
    build_container
    save_build_result
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
  
end