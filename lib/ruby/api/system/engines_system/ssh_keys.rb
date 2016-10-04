module SshKeys
  def generate_engines_user_ssh_key
    newkey = regen_system_ssh_key # SystemUtils.run_command(SystemConfig.generate_ssh_private_keyfile)
    return log_error_mesg("Not an RSA key",newkey) unless newkey.include?('-----BEGIN RSA PRIVATE KEY-----')
    return newkey
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def update_public_key(key)
  
    run_server_script('update_system_access', key)[:stdout]
    rescue StandardError => e
        SystemUtils.log_exception(e)
  end

  def regen_system_ssh_key
    run_server_script('regen_private')[:stdout]
  end
  
  def get_public_key
    run_server_script('public_key')[:stdout]
#/home/engines/.ssh/console_access.pub
  rescue StandardError => e
    log_exception(e)
  end

end