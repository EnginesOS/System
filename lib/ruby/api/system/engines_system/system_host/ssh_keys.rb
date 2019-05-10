module SshKeys
  def generate_engines_user_ssh_key
    newkey = regen_system_ssh_key # SystemUtils.run_command(SystemConfig.generate_ssh_private_keyfile)
    raise EnginesException.new(error_hash('Not an RSA key', newkey)) unless newkey.include?('-----BEGIN RSA PRIVATE KEY-----')
    newkey
  end

  def update_user_public_key(key)
    r = run_server_script('update_system_access', key)
    if r[:result] == 0
      true
    else
      false
    end
  end

  def set_ms_public_key(key_data)
    keyf = File.new('/home/engines/.ssh/mother_ship.pub','w+')
    keyf.write(key_data)
    keyf.close
  end

  def get_ms_public_key
    if File.exists?('/home/engines/.ssh/mother_ship.pub')
      File.read('/home/engines/.ssh/mother_ship.pub')
    else
      raise EnginesException.new(warning_hash('No mother ship key', 'No mother ship key'))
    end
  end

  def get_system_public_key
    if File.exists?('/home/engines/.ssh/engines_system.pub')
      File.read('/home/engines/.ssh/engines_system.pub')
    else
      run_server_script('system_public_key')[:stdout]
    end

  end

  def get_repo_keys_names
    {repo_key_names: ['system']}
  end

  def regen_system_ssh_key
    run_server_script('regen_private')[:stdout]
  end

  def get_user_public_key
    if File.exists?('/home/engines/.ssh/console_access.pub ')
      File.read('/home/engines/.ssh/console_access.pub ')
    else
      raise EnginesException.new(warning_hash('No access key', 'Generate with system action'))
    end
  end

end