module PublicApiEngineActionators
  def list_engine_actionators(engine)
    @system_api.load_engine_actionators(engine)
  end

  def get_engine_actionator(engine, action)
    @system_api.get_engine_actionator(engine, action)
  end

  def perform_engine_action(engine, actionator_name, params)
    @core_api.perform_engine_action(engine, actionator_name, params)
  end

end