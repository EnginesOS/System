module CertificateActions
  #  def get_system_ca
  #    @system_api.get_system_ca
  ##    return "No CA found" unless File.exists?(SystemConfig.EnginesInternalCA)
  ##    File.read(SystemConfig.EnginesInternalCA)
  ##
  ##  rescue StandardError => e
  ##    return log_exception(e,'Failed to load CA')
  #
  #  end
  def upload_ssl_certificate(params)
    return log_error_mesg('invalid parameter', 'upload Cert ', params.to_s) unless params.is_a?(Hash)
    unless params.has_key?(:certificate) || params.key?(:domain_name)
      return log_error_mesg('error expect keys  :certificate :domain_name with optional :use_as_default', 'uploads cert', params.to_s)
    end
    @system_api.upload_ssl_certificate(params)
  rescue StandardError => e
    log_exception(e,'Failed to install cert',domain)
  end

  def get_cert(domain)
    @system_api.get_cert(domain)
  rescue StandardError => e
    log_exception(e,'Failed to load cert',domain)
  end

  def remove_cert(domain)
    @system_api.remove_cert(domain)
  rescue StandardError => e
    log_exception(e,'Failed to remove cert',domain)
  end

  def list_certs
    @system_api.list_certs()
  rescue StandardError => e
    log_exception(e,'Failed to list certs')
  end

  def containers_certificates(container)

    q = {:container_type => container.ctype, :parent_engine => container.container_name, :publisher_namespace => 'EnginesSytem', :type_path => 'cert_auth' }
    r = service_manager.find_engine_services_hashes(q)
    STDERR.puts( " CERTIS " + r.to_s)
    r
  rescue StandardError => e
    return log_exception(e,'Failed to list registered certs ')
  end

end