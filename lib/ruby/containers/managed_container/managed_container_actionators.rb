module ManagedContainerActionators
 def perform_action(actionator_name,params)
  @container_api.perform_action(actionator_name,params)
 end
end