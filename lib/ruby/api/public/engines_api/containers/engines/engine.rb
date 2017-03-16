module PublicApiEngine
  def loadManagedEngine(engine_name)   #vc engines system
    @system_api.loadManagedEngine(engine_name)
  rescue StandardError => e
    handle_exception(e)
  end

  def get_resolved_engine_string #ex
    @core_api.get_resolved_engine_string(env_value, engine)
  rescue StandardError => e
    handle_exception(e)
  end

  def get_build_report(engine_name)
    @core_api.get_build_report(engine_name)
  rescue StandardError => e
    handle_exception(e)
  end

  def reinstall_engine(engine)
    @core_api.reinstall_engine(engine)
  rescue StandardError => e
    handle_exception(e)
  end

end