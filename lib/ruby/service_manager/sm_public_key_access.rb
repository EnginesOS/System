module SmPublicKeyAccess
  def load_service_pubkey(engine, cmd)
    load_pubkey(engine, cmd)
  end

  def load_pubkey(engine, cmd)
    kfn = SystemConfig.container_ssh_keydir(engine) + '/' + cmd.to_s + '_rsa.pub'
    if File.exists?(kfn)
      k = File.read(kfn)
      k.split(' ')[1]
    else
      ''
    end
  end

end