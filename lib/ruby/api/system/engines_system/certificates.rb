module Certificates
  def upload_ssl_certificate(params)
    certs_service = loadManagedService('cert_auth')
    actionator = get_service_actionator(certs_service, 'import_cert')
    certs_service.perform_action(actionator, params) #[:domain_name], params[:certificate] + params[:private_key])
  end

  def remove_cert(params)
    certs_service = loadManagedService('cert_auth')
    actionator = get_service_actionator(certs_service, 'remove_cert')
    certs_service.perform_action(actionator, params)
    unless params[:store].nil? || params[:store] == '/'  || params[:store] == '.'  || params[:store] == 'uploaded'
      service = { container_type: File.dirname(params[:store]).gsub(/\//,''),
        parent_engine: File.basename(params[:store]).gsub(/\//,''),
        publisher_namespace: 'EnginesSystem',
        type_path: 'cert_auth',
        service_handle: params[:cert_name]
      }
      STDERR.puts('CERT SERVICe IS ' + service.to_s)
      begin
        s = retrieve_engine_service_hash(service)
      rescue
        s = nil
      end
      clear_service_from_registry(service) unless s.nil?
    end
  end

  def set_default_cert(params)
    certs_service = loadManagedService('cert_auth')
    actionator = get_service_actionator(certs_service, 'set_default')
    certs_service.perform_action(actionator, params)
  end

  def list_certs
    certs_service = loadManagedService('cert_auth')
    actionator = get_service_actionator(certs_service, 'list_certs')
    certs_service.perform_action(actionator)[:certs]
  end

  def services_default_certs
    certs_service = loadManagedService('cert_auth')
    actionator = get_service_actionator(certs_service, 'list_services_defaults')
    certs_service.perform_action(actionator)[:certs]
  end

  def get_system_ca
    certs_service = loadManagedService('cert_auth')
    actionator = get_service_actionator(certs_service, 'system_ca')
    certs_service.perform_action(actionator)
  end

  def generate_cert(params)
    certs_service = loadManagedService('cert_auth')

    params[:type_path] = 'cert_auth'
    params[:service_container_name] = 'cert_auth'
    params[:persistent] = true
    params[:publisher_namespace] = 'EnginesSystem'
    params[:service_handle] = params[:domain_name]

    begin
      actionator = get_service_actionator(certs_service, 'fetch_cert')
      c = certs_service.perform_action(actionator, {cert_name: params[:container_type] +'_' + params[:parent_engine]  + '_' + params[:domain_name]})

      #  STDERR.puts('GTO c ' + c.to_s)
      if c.include?('BEGIN CERTIFICATE')
        return false unless params.key?(:overwrite)
      end
      # FixME
      #return raise EnginesException(....) instead of return false
      @engines_api.dettach_service(params)
    rescue
      #no cert exception is what we want
    end

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
      country: params[:country],
      state: params[:state],
      city: params[:city],
      organisation: params[:organisation],
      person: params[:person],
      domainname:  params[:domain_name], #params[:default_domain]
      service_handle: params[:domain_name]
      }
    } )
  end

  def get_cert(params)
    certs_service = loadManagedService('cert_auth')
    cert_name = 'engines' if cert_name == 'default'
    actionator = get_service_actionator(certs_service, 'fetch_cert')
    certs_service.perform_action(actionator, params)
  end

end