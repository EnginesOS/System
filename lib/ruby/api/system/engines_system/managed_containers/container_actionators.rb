module ContainerActionators
  def get_service_actionator(container, action)
    actionators = load_service_actionators(container)
    actionators[action.to_sym]
  end

  def load_service_actionators(container)
    SoftwareServiceDefinition.actionators({
      type_path: container.type_path, publisher_namespace: container.publisher_namespace })
  end

  def get_engine_actionator(engine, action)
    actionators = load_engine_actionators(engine)
    #    SystemDebug.debug(SystemDebug.actions, container, actionators[action]) #.to_sym])
    actionators[action]
  end

  def load_engine_actionators(engine)
    ContainerStateFiles.load_engine_actionators(engine.store_address)
  end

  def write_actionators(engine, actionators)
    unless actionators.nil?
      ContainerStateFiles.write_actionators(engine, actionators)
    end
  end
end
