module SystemOperations
  def restart_system
    GC.start
        ObjectSpace.dump(@system_api,output: File.open('/var/log/apache2/system.json','w'))
        ObjectSpace.dump(self, output: File.open('/var/log/apache2/engines.json','w'))
        ObjectSpace.dump_all(output: File.open('/var/log/apache2/heap.json','w'))
        ObjectSpace.dump(@registry_handler,output: File.open('/var/log/apache2/registry_handler.json','w'))
        ObjectSpace.dump(@container_api,output: File.open('/var/log/apache2/container_api.json','w'))
        ObjectSpace.dump(@service_api,output: File.open('/var/log/apache2/service_api.json','w'))
        ObjectSpace.dump(@docker_api,output: File.open('/var/log/apache2/docker_api.json','w'))
    test_system_api_result(@system_api.restart_system)
  end

  def restart_mgmt
    test_system_api_result(@system_api.restart_mgmt)
  end

  def update_engines_system_software
    test_system_api_result(@system_api.update_engines_system_software)
  end

  def update_system
    test_system_api_result(@system_api.update_system)
  end

  def generate_engines_user_ssh_key
    test_system_api_result(@system_api.regen_system_ssh_key)
  end

  def update_public_key(key)
    test_system_api_result(@system_api.update_public_key(key))
  end

  def generate_engines_user_ssh_key
    test_system_api_result(@system_api.generate_engines_user_ssh_key)
  end

  def system_update
    test_system_api_result(@system_api.update_system)
  end

  def enable_remote_exception_logging
    test_system_api_result(@system_api.enable_remote_exception_logging)
  end

  def disable_remote_exception_logging
    test_system_api_result(@system_api.disable_remote_exception_logging)
  end

  def set_engines_ssh_pw(params)
    pass = params[:ssh_password]
    cmd = 'echo -e ' + pass + "\n" + pass + ' | passwd engines'
    SystemUtils.debug_output('ssh_pw', cmd)
    SystemUtils.run_system(cmd)
  end

  def upload_ssl_certificate(params)
    @system_api.upload_ssl_certificate(params)
  end

  def system_image_free_space
    @system_api.system_image_free_space
  end
  
  def system_hostname
    @system_api.system_hostname
end

end