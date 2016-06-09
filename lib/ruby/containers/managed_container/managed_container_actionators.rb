module ManagedContainerActionators
 def perform_action(actionator_name,params, data=nil)
   STDERR.puts(actionator_name.to_s + ' ' +params.to_s + ' DATAAA ' + data.to_s )
  @container_api.perform_action(self,actionator_name,params,data)
   rescue StandardError => e
            log_exception( e,'perform_engine_action',actionator_name,params)
 end
end