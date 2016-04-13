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
   SystemUtils.run_command('/opt/engines/scripts/setup_service_dir.sh ' + container_name)
  setup_service_keys if @system_keys.is_a?(Array)
  SystemDebug.debug(SystemDebug.containers, :keys_set,  @system_keys )
 
   
   envs = @container_api.load_and_attach_pre_services(self)
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
      
       @environments =  EnvironmentVariable.merge_envs(envs,@environments)    
     else
       @environments = envs
     end
   end
  @container_api.setup_service_dirs(self)

   if create_container

     service_configurations = @container_api.get_service_configurations_hashes({service_name: @container_name})
     if service_configurations.is_a?(Array)
       service_configurations.each do |configuration|
         run_configurator(configuration)
       end
     end
    # register_with_dns
     @container_api.load_and_attach_post_services(self)
   #  @container_api.register_non_persistent_services(self)
     reregister_consumers
     return true
   else
      save_state()
     return log_error_mesg('Failed to create service',last_error)
   end
    
rescue StandardError =>e
  log_exception(e)
 end

 def recreate
 
   if destroy_container
     return true if create_service
     save_state()
     return log_error_mesg('Failed to create service in recreate',self)
   else
     save_state()
     return log_error_mesg('Failed to destroy service in recreate',self)
   end
 end
 
 private
 def setup_service_keys
   keys = ''
       @system_keys.each do |key|
         keys += ' ' + key.to_s
       end
   SystemDebug.debug(SystemDebug.containers, :keys, keys )
    SystemUtils.run_command('/opt/engines/scripts/setup_service_keys.sh ' + container_name  + keys)
 end

 
end