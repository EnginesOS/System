module ManagedContainerCertificates
  
  def certificates
    container_dock.certificates(self)
  end
end