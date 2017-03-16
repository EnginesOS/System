module PublicApiSystemCertificates
  def get_system_ca
    @system_api.get_system_ca
  end

  def upload_ssl_certificate(params)
    return log_error_mesg('invalid parameter', 'upload Cert ', params.to_s) unless params.is_a?(Hash)
    unless params.has_key?(:certificate) || params.key?(:domain_name)
      return log_error_mesg('error expect keys  :certificate :domain_name with optional :use_as_default', 'uploads cert', params.to_s)
    end
    @system_api.upload_ssl_certificate(params)
  rescue StandardError => e
    handle_exception(e)
  end

  def generate_cert(params)
    @system_api.generate_cert(params)
  rescue StandardError => e
    handle_exception(e)
  end

  def get_cert(domain)
    @system_api.get_cert(domain)
  rescue StandardError => e
    handle_exception(e)
  end

  def remove_cert(domain)
    @system_api.remove_cert(domain)
  rescue StandardError => e
    handle_exception(e)
  end

  def list_certs
    @system_api.list_certs()
  rescue StandardError => e
    handle_exception(e)
  end

end
