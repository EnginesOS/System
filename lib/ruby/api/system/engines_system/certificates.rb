module Certificates
  def upload_ssl_certificate(params)
    certs_service = loadManagedService('cert_auth')
    actionator = get_service_actionator(certs_service, 'import_cert')  
    certs_service.perform_action(actionator ,params[:domain_name], params[:certificate] + params[:key])
  end

  def remove_cert(domain_name)
    certs_service = loadManagedService('cert_auth')
    actionator = get_service_actionator(certs_service, 'remove_cert')    
    certs_service.perform_action(actionator, domain_name)
  end

  def list_certs
    certs_service = loadManagedService('cert_auth')
    actionator = get_service_actionator(certs_service, 'list_certs')    
    certs_service.perform_action(actionator, nil)
  end

  def get_system_ca
    certs_service = loadManagedService('cert_auth')
    actionator = get_service_actionator(certs_service, 'system_ca')    
    certs_service.perform_action(actionator, nil)
  end

  def generate_cert(params)
    certs_service = loadManagedService('cert_auth')
    actionator = get_service_actionator(certs_service, 'fetch_cert')    
    c = certs_service.perform_action(actionator, params[:variables][:domainname])
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
    actionator = get_service_actionator(certs_service, 'fetch_cert')   
    certs_service.perform_action(actionator, domain_name)
  end

end