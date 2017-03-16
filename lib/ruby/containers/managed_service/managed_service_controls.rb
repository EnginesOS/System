module ManagedServiceControls
  

  def start_container
    super
   
  end
  
def create_service()
   #SystemUtils.run_command('/opt/engines/system/scripts/system/setup_service_dir.sh ' + container_name)
  setup_service_keys if @system_keys.is_a?(Array)
  @container_api.setup_service_dirs(self)
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
 
     create_container
     save_state()

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
    SystemUtils.run_command('/opt/engines/system/scripts/system/setup_service_keys.sh ' + container_name  + keys)
 end

 
end