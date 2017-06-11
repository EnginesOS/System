module Builders
  
  require_relative 'builder/builder_blueprint.rb'
  include BuilderBluePrint
  
  def rebuild_managed_container(engine)
    @engine = engine
    @rebuild = true
    log_build_output('Starting Rebuild')
    backup_lastbuild
    setup_rebuild
    build_container
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
  rescue StandardError => e
    post_failed_build_clean_up
    log_exception(e)
  end
end