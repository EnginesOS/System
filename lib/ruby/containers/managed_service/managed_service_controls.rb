module ManagedServiceControls
  

  def start_container
    super
    service_configurations = @container_api.get_pending_service_configurations_hashes({service_name: @container_name})
    if service_configurations.is_a?(Array)
      service_configurations.each do |configuration|
        @container_api.update_service_configuration(configuration)
      end
    end
  end
  
def create_service()
   SystemUtils.run_command('/opt/engines/scripts/setup_service_dir.sh ' +container_name)
   envs = @container_api.load_and_attach_persistant_services(self)
   shared_envs = @container_api.load_and_attach_shared_services(self)
   if shared_envs.is_a?(Array)
     if envs.is_a?(Array) == false
       envs = shared_envs
     else
       #envs.concat(shared_envs)
       envs = EnvironmentVariable.merge_envs(shared_envs,envs)
     end
   end
   if envs.is_a?(Array)
     if@environments.is_a?(Array)
       SystemUtils.debug_output( :envs, @environments)
       @environments =  EnvironmentVariable.merge_envs(envs,@environments)    
     else
       @environments = envs
     end
   end
 
   if create_container
     #save_state()
     #return false unless super
     service_configurations = @container_api.get_service_configurations_hashes({service_name: @container_name})
     if service_configurations.is_a?(Array)
       service_configurations.each do |configuration|
         run_configurator(configuration)
       end
     end
    # register_with_dns
     @container_api.load_and_attach_nonpersistant_services(self)
   #  @container_api.register_non_persistant_services(self)
     reregister_consumers
     return true
   else
      save_state()
     return log_error_mesg('Failed to create service',last_error)
   end
 end

 def recreate
 
   if  destroy_container
     return true if create_service
     save_state()
     return log_error_mesg('Failed to create service in recreate',self)
   else
     save_state()
     return log_error_mesg('Failed to destroy service in recreate',self)
   end
 end

 
end