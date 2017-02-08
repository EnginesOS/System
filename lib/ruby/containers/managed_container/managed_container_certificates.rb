module ManagedContainerCertificates
  
  def certificates
    @container_api.certificates(self)
  end
end