module PublicApiEngines
  def list_managed_engines
    @system_api.list_managed_engines
  end

  def getManagedEngines
    @system_api.getManagedEngines
  end

  def clear_lost_engines
    core.clear_lost_engines
  end

  def get_engines_states
    @system_api.get_engines_states
  end

  def get_engines_status
    @system_api.get_engines_status
  end

  def build_engine(params)
    core.build_engine(params)
  end

  def delete_engine(params)
    core.delete_engine_and_services(params)
  end

end
