module SshKeys
  def generate_engines_user_ssh_key
    newkey = regen_system_ssh_key # SystemUtils.run_command(SystemConfig.generate_ssh_private_keyfile)
    raise EnginesException.new(error_hash("Not an RSA key", newkey)) unless newkey.include?('-----BEGIN RSA PRIVATE KEY-----')
     newkey
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def update_public_key(key)  
    r =  run_server_script('update_system_access', key)
    return r if r.is_a?(EnginesError) 
    true
    rescue StandardError => e
        SystemUtils.log_exception(e)
  end

  def regen_system_ssh_key
   r=   run_server_script('regen_private')
   return r if r.is_a?(EnginesError) 
    r[:stdout]
  end
  
  def get_public_key
    r = run_server_script('public_key')
    return r if r.is_a?(EnginesError) 
     r[:stdout]
      
#/home/engines/.ssh/console_access.pub
  rescue StandardError => e
    log_exception(e)
  end

end