module Certificates
  def upload_ssl_certificate(params)
    certs_service = loadManagedService('cert_auth')
    certs_service.perform_action('import_cert',params[:domain_name], params[:certificate] + params[:key])
  end

  def remove_cert(domain_name)
    certs_service = loadManagedService('cert_auth')
    certs_service.perform_action('remove_cert',domain_name)
  end

  def list_certs
    certs_service = loadManagedService('cert_auth')
    certs_service.perform_action('list_certs',nil)
  end

  def get_system_ca
    certs_service = loadManagedService('cert_auth')
    certs_service.perform_action('system_ca',nil)
  end

  def generate_cert(params)
    certs_service = loadManagedService('cert_auth')
    c = certs_service.perform_action('fetch_cert', params[:variables][:domainname])
    if c == "a_cert"
      #bail if not overrite
      return false
    end
    params[:type_path] = 'cert_auth'
    params[:service_container_name] = 'cert_auth'
    params[:persistent] = true
    params[:publisher_namespace] = 'EnginesSystem'
    @engines_api.create_and_register_service(params)
  end

  def get_cert(domain_name)
    certs_service = loadManagedService('cert_auth')
    domain_name = 'engines' if domain_name == 'default'
    certs_service.perform_action('fetch_cert', domain_name)
  end

end