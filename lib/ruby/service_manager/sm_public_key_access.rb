module SmPublicKeyAccess
  def load_service_pubkey(engine, cmd)
    load_pubkey(engine, cmd)
  end

  def load_pubkey(engine, cmd)
    kfn = SystemConfig.container_ssh_keydir(engine) + '/' + cmd.to_s + '_rsa.pub'
    return '' unless File.exists?(kfn)
    k = File.read(kfn)
    k.split(' ')[1]
  rescue StandardError => e
    handle_exception(e)
  end

end