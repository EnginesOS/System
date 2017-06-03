module ManagedContainerActionators
  def perform_action(actionator, params, data = nil)
    SystemDebug.debug(SystemDebug.actions, actionator, params, data)
    @container_api.perform_action(self, actionator, params, data)
  end
end