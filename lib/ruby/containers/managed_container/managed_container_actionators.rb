module ManagedContainerActionators
 def perform_action(actionator_name,params, data=nil)
  @container_api.perform_action(self,actionator_name,params, data)
 end
end