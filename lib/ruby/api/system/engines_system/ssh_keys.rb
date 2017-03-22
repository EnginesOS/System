module SshKeys
  def generate_engines_user_ssh_key
    newkey = regen_system_ssh_key # SystemUtils.run_command(SystemConfig.generate_ssh_private_keyfile)
    raise EnginesException.new(error_hash("Not an RSA key", newkey)) unless newkey.include?('-----BEGIN RSA PRIVATE KEY-----')
    newkey
  end

  def update_public_key(key)
   run_server_script('update_system_access', key)
    true
  end

  def regen_system_ssh_key
    r = run_server_script('regen_private')
    r[:stdout]
  end

  def get_public_key
    r = run_server_script('public_key')
    r[:stdout]
  end

end