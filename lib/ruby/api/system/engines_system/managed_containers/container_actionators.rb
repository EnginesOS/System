module ContainerActionators
  def get_service_actionator(container, action)
    actionators = load_service_actionators(container)
    actionators[action.to_sym]
  end

  def load_service_actionators(container)
    SoftwareServiceDefinition.actionators({
      type_path: container.type_path, publisher_namespace: container.publisher_namespace })
  end

  def get_engine_actionator(ca, action)
    actionators = load_engine_actionators(ca)
    #    SystemDebug.debug(SystemDebug.actions, container, actionators[action]) #.to_sym])
    actionators[action]
  end

  def load_engine_actionators(ca)
    ContainerStateFiles.load_engine_actionators(ca)
  end

  def write_actionators(ca, actionators)
    unless actionators.nil?
      ContainerStateFiles.write_actionators(ca, actionators)
    end
  end
end
