module SystemOperations
  def restart_system
  #  GC.start
#        ObjectSpace.dump(@system_api.freeze,output: File.open('/var/log/apache2/system.json','w'))
#        ObjectSpace.dump(self.freeze, output: File.open('/var/log/apache2/engines.json','w'))
#        ObjectSpace.dump_all(output: File.open('/var/log/apache2/heap.json','w'))
#        ObjectSpace.dump(@registry_handler.freeze,output: File.open('/var/log/apache2/registry_handler.json','w'))
#        ObjectSpace.dump(@container_api.freeze,output: File.open('/var/log/apache2/container_api.json','w'))
#        ObjectSpace.dump(@service_api.freeze,output: File.open('/var/log/apache2/service_api.json','w'))
#        ObjectSpace.dump(@docker_api.freeze,output: File.open('/var/log/apache2/docker_api.json','w'))
    @system_api.restart_system
  end
 
#  def restart_engines_system
#    @system_api.restart_engines_system
#  end

  def restart_engines_system_service
    @system_api.restart_engines_system_service
  end
  
  def update_engines_system_software
    @system_api.update_engines_system_software
  end

  def update_base_os
    @system_api.update_base_os
  end

#  def generate_engines_user_ssh_key
#    test_system_api_result(@system_api.regen_system_ssh_key)
#  end

  def update_public_key(key)
    @system_api.update_public_key(key)
  end

  def generate_engines_user_ssh_key
    @system_api.generate_engines_user_ssh_key
  end

#  def system_update
#    @system_api.update_system
#  end

  def enable_remote_exception_logging
    @system_api.enable_remote_exception_logging
  end

  def disable_remote_exception_logging
    @system_api.disable_remote_exception_logging
  end

  def set_engines_ssh_pw(params)
    pass = params[:ssh_password]
    cmd = 'echo -e ' + pass + "\n" + pass + ' | passwd engines'
    SystemDebug.debug(SystemDebug.system,'ssh_pw', cmd)
    SystemUtils.run_system(cmd)
  end
  
  def get_public_key
    @system_api.get_public_key
  end

  def system_image_free_space
    @system_api.system_image_free_space
  end
  
  def available_ram
    @system_api.available_ram
  end
  
  def system_hostname
    @system_api.system_hostname
end

end