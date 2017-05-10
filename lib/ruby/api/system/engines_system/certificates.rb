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
    if c == 'a_cert'
      #bail if not overrite
      return false
    end
    params[:type_path] = 'cert_auth'
    params[:service_container_name] = 'cert_auth'
    params[:persistent] = true
    params[:publisher_namespace] = 'EnginesSystem'

    @engines_api.create_and_register_service({
      parent_engine: params[:parent_engine],
      type_path: 'cert_auth',
      service_container_name: 'cert_auth',
      container_type: params[:container_type],
      persistent: true,
      publisher_namespace: 'EnginesSystem',
      service_handle: params[:domain_name],
      variables: {
      wild: params[:wild],
      cert_name: params[:domain_name],
      country: params[:ssl_country],
      state: params[:ssl_state],
      city: params[:ssl_city],
      organisation: params[:ssl_organisation_name],
      person: params[:ssl_person_name],
      domainname:  params[:domain_name], #params[:default_domain]
      service_handle: params[:domain_name]
      }
    } )
  end

  def get_cert(domain_name)
    certs_service = loadManagedService('cert_auth')
    domain_name = 'engines' if domain_name == 'default'
    actionator = get_service_actionator(certs_service, 'fetch_cert')
    certs_service.perform_action(actionator, domain_name)
  end

end