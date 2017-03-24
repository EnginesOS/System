module CertificateActions
  def upload_ssl_certificate(params)
    raise EnginesException.new(error_hash('invalid parameter', 'upload Cert ', params.to_s)) unless params.is_a?(Hash)
    unless params.has_key?(:certificate) || params.key?(:domain_name)
      raise EnginesException.new(error_hash('error expect keys  :certificate :domain_name with optional :use_as_default', 'uploads cert', params.to_s))
    end
    @system_api.upload_ssl_certificate(params)
  end

  def get_cert(domain)
    @system_api.get_cert(domain)
  end

  def remove_cert(domain)
    @system_api.remove_cert(domain)
  end

  def list_certs
    @system_api.list_certs()
  end

  def containers_certificates(container)
    find_engine_services_hashes({
      container_type:  container.ctype, 
      parent_engine: container.container_name,
      publisher_namespace: 'EnginesSytem',
      type_path: 'cert_auth' })
  end

end