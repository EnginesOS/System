module PublicApiEngine
  def loadManagedEngine(engine_name)   #vc engines system
    @system_api.loadManagedEngine(engine_name)
  end

  def get_resolved_engine_string #ex
    @core_api.get_resolved_engine_string(env_value, engine)
  end

  def set_debug(engine_name)
    loadManagedEngine(engine_name).set_debug
  end
  
  def clear_debug
    loadManagedEngine(engine_name).clear_debug
  end
  
  def get_build_report(engine_name)
    @core_api.get_build_report(engine_name)
  end

  def reinstall_engine(engine)
    @core_api.reinstall_engine(engine)
  end
  def user_clear_error(container)
    @core_api.user_clear_error(container)
  end
end