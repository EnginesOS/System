module ManagedContainerActionators
  def perform_action(actionator_name,params, data=nil)
    SystemDebug.debug(SystemDebug.actions, actionator_name,params, data)
    @container_api.perform_action(self,actionator_name,params,data)
  end
end