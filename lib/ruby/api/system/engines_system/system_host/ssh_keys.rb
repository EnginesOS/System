module SshKeys
  def generate_engines_user_ssh_key
    newkey = regen_system_ssh_key 
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
    keyf = File.new('/home/engines/.ssh/system/mother_ship.pub','w+')
    begin
      keyf.write(key_data)
    ensure
      keyf.close
    end
  end

  def get_ms_public_key
    if File.exists?('/home/engines/.ssh/system/mother_ship.pub')
      File.read('/home/engines/.ssh/system/mother_ship.pub')
    else
      raise EnginesException.new(warning_hash('No mother ship key', 'No mother ship key'))
    end
  end

  def get_system_public_key
    if File.exists?('/home/engines/.ssh/system/engines_system.pub')
      File.read('/home/engines/.ssh/system/engines_system.pub')
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
    if File.exists?('/home/engines/.ssh/system/console_access.pub')
      File.read('/home/engines/.ssh/system/console_access.pub')
    else
      raise EnginesException.new(warning_hash('No access key', 'Generate with system action'))
    end
  end

end