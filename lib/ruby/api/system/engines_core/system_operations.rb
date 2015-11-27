module SystemOperations
  def restart_system
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

end