module PublicApiService
  def loadManagedService(service_name)
    @system_api.loadManagedService(service_name)
  end

  def get_resolved_engine_string(env_value, engine)
    core.get_resolved_engine_string(env_value, engine)
  end

  def get_resolved_service_hash(service_hash)
    core.fillin_template_for_service_def(service_hash)
  end

  def update_service_configuration(service_param)
    core.update_service_configuration(service_param)
  end

end
