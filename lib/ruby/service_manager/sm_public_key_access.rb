module SmPublicKeyAccess
  def load_service_pubkey(ca, cmd)
    load_pubkey(engine, cmd)
  end

  def load_pubkey(ca, cmd)
    ContainerStateFiles.load_pubkey(ca, cmd)
  end
end