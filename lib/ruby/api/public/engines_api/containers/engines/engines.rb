module PublicApiEngines
  def list_managed_engines
    @system_api.list_managed_engines
  rescue StandardError => e
    handle_exception(e)
  end

  def getManagedEngines
    @system_api.getManagedEngines
  rescue StandardError => e
    handle_exception(e)
  end

  def get_engines_states
    @system_api.get_engines_states
  rescue StandardError => e
    handle_exception(e)
  end

  def get_engines_status
    @system_api.get_engines_status
  rescue StandardError => e
    handle_exception(e)
  end

  def  build_engine(params)
    @core_api.build_engine(params)
  rescue StandardError => e
    handle_exception(e)
  end

  def delete_engine(params)
    @core_api.delete_engine(params)
  rescue StandardError => e
    handle_exception(e)
  end

end