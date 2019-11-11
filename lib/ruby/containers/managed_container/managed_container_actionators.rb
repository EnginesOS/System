module ManagedContainerActionators
  def perform_action(actionator, params = nil, data = nil)
    # SystemDebug.debug(SystemDebug.actions, actionator, params, data)
    container_dock.perform_action(self, actionator, params, data)
  end
end