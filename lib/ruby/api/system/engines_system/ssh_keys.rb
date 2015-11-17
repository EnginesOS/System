module SshKeys
  def generate_engines_user_ssh_key
    newkey = regen_system_ssh_key # SystemUtils.run_command(SystemConfig.generate_ssh_private_keyfile)
    return log_error_mesg("Not an RSA key",newkey) unless newkey.include?('-----BEGIN RSA PRIVATE KEY-----')
    return newkey
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def update_public_key(key)
    SystemUtils.execute_command('ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/update_system_access engines@172.17.42.1 /opt/engines/bin/update_system_access.sh ' + key)
  end

  def regen_system_ssh_key
    SystemUtils.run_command('ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/regen_private engines@172.17.42.1 /opt/engines/bin/regen_private.sh ')
  end

  
end