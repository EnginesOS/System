module PublicApiSystemCertificates
  def get_system_ca
    @system_api.get_system_ca
  end

  def upload_ssl_certificate(params)
    unless params.is_a?(Hash)
      log_error_mesg('invalid parameter', 'upload Cert ', params.to_s)
    else
      unless params.has_key?(:certificate) || params.key?(:domain_name)
        raise EnginesException.new(error_hash('error expect keys  :certificate :domain_name with optional :set_as_default', 'uploads cert', params))
      end
      params[:install_target] = 'default' if params[:set_as_default] == true
      @system_api.upload_ssl_certificate(params)
    end
    true
  end

  def set_default_cert(params)
    @system_api.set_default_cert(params)
  end

  def generate_cert(params)
    @system_api.generate_cert(params)
  end

  def get_cert(params)
    STDERR.puts('GET ' + params.to_s)
    @system_api.get_cert(params)
  end

  def remove_cert(params)
    
    STDERR.puts('REMOV ' + params.to_s)
    @system_api.remove_cert(params)
  end

  def list_certs
    @system_api.list_certs
  end

  def services_default_certs
    r = @system_api.services_default_certs
    STDERR.puts(' SERVICE DEFAULT CERTS ' + r.class.name + ':' + r.to_s)
      r
  end
end
