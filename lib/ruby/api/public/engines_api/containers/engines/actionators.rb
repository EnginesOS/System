module PublicApiEngineActionators
  def list_engine_actionators(ca)
    system_api.load_engine_actionators(ca)
  end

  def get_engine_actionator(ca, action)
    system_api.get_engine_actionator(ca, action)
  end

  def perform_engine_action(engine, actionator, params)
    core.perform_engine_action(engine, actionator, params)
  end

end
