module SystemOperations
  def restart_system
    @system_api.restart_system
  end

  def restart_engines_system_service
    @system_api.restart_engines_system_service
  end

  def update_engines_system_software
    @system_api.update_engines_system_software
  end

  def update_base_os
    @system_api.update_base_os
  end

  def update_public_key(key)
    @system_api.update_public_key(key)
  end

  def generate_engines_user_ssh_key
    @system_api.generate_engines_user_ssh_key
  end

  def enable_remote_exception_logging
    @system_api.enable_remote_exception_logging
  end

  def disable_remote_exception_logging
    @system_api.disable_remote_exception_logging
  end

  def set_engines_ssh_pw(params)
    pass = params[:ssh_password]
    cmd = 'echo -e ' + pass + "\n" + pass + ' | passwd engines'
#    SystemDebug.debug(SystemDebug.system,'ssh_pw', cmd)
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