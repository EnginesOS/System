module Certificates
  def upload_ssl_certificate(params)

    certs_service = loadManagedService('cert_auth')
    return certs_service if certs_service.is_a?(EnginesError)

    certs_service.perform_action('import_cert',params[:domain_name], params[:certificate] + params[:key])
  rescue StandardError =>e
    log_exception(e)
  end

  def remove_cert(domain_name)
    certs_service = loadManagedService('cert_auth')
    return certs_service if certs_service.is_a?(EnginesError)

    certs_service.perform_action('remove_cert',domain_name)
  end

  def list_certs
    certs_service = loadManagedService('cert_auth')
    return certs_service if certs_service.is_a?(EnginesError)
    certs_service.perform_action('list_certs',nil)
  rescue StandardError =>e
    log_exception(e)
  end

  def get_system_ca

    certs_service = loadManagedService('cert_auth')
    return certs_service if certs_service.is_a?(EnginesError)
    certs_service.perform_action('system_ca',nil)
  rescue StandardError =>e
    log_exception(e)
  end

  def get_cert(domain_name)
    certs_service = loadManagedService('cert_auth')

    return certs_service if certs_service.is_a?(EnginesError)

    domain_name = 'engines' if domain_name == 'default'
    certs_service.perform_action('fetch_cert', domain_name)
  rescue StandardError =>e
    log_exception(e)

  end

end