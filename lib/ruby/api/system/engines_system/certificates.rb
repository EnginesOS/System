class SystemApi
  def upload_ssl_certificate(params)
    certs_service = loadManagedService('certs')
  #  STDERR.puts(' Cert  ' +  params[:certificate] )
  #  STDERR.puts(' KEY  ' +  params[:private_key] )
    actionator = get_service_actionator(certs_service, 'import_cert')
    certs_service.perform_action(actionator, params)
  end

  def remove_cert(params)
    certs_service = loadManagedService('certs')
    actionator = get_service_actionator(certs_service, 'remove_cert')

    unless params[:store].nil? || params[:store].start_with?('imported')
      service = { container_type: container_type(params[:store]),
        parent_engine: engine_name(params[:store]),
        publisher_namespace: 'EnginesSystem',
        type_path: 'certs',
        service_handle: params[:cert_name]
      }
     # STDERR.puts('CERT SERVICe IS:' + service.to_s)
       s = core.retrieve_engine_service_hash(service)
     #   STDERR.puts('CERT SERVICe R:' + s.to_s)
      unless s.nil?
      core.dettach_service(service)
      else
        raise EnginesException.new(error_hash('Cert service entry  not found' + service.to_s))
      end
    else #imported action
      certs_service.perform_action(actionator, params)
    end
    true
  end

  def engine_name(store)
    File.basename(store).gsub(/\//, '')
  end

  def container_type(store)
    File.dirname(store).gsub(/\//, '').gsub(/s$/, '')
  rescue
    nil
  end

  def set_default_cert(params)
    certs_service = loadManagedService('certs')
    actionator = get_service_actionator(certs_service, 'set_default')
    certs_service.perform_action(actionator, params)
    true
  end

  def list_certs
    certs_service = loadManagedService('certs')
    actionator = get_service_actionator(certs_service, 'list_certs')
    certs_service.perform_action(actionator)[:certs]
  end

  def services_default_certs
    certs_service = loadManagedService('certs')
    actionator = get_service_actionator(certs_service, 'list_services_defaults')
    certs_service.perform_action(actionator)[:certs]
  end

  def get_system_ca
    certs_service = loadManagedService('certs')
    actionator = get_service_actionator(certs_service, 'system_ca')
    certs_service.perform_action(actionator)
  end

  def generate_cert(params)
    certs_service = loadManagedService('certs')

    params[:type_path] = 'certs'
    params[:service_container_name] = 'certs'
    params[:persistent] = true
    params[:publisher_namespace] = 'EnginesSystem'
    params[:service_handle] = params[:domain_name]

    begin
      actionator = get_service_actionator(certs_service, 'fetch_cert')
      c = certs_service.perform_action(actionator, {cert_name: "#{params[:container_type]}_#{params[:parent_engine]}_#{params[:domain_name]}" })

      #  STDERR.puts('GTO c ' + c.to_s)
      if c.include?('BEGIN CERTIFICATE')
        return false unless params.key?(:overwrite)
      end
      # FixME
      #return raise EnginesException(....) instead of return false
      core.dettach_service(params)
    rescue
      #no cert exception is what we want
    end

    core.create_and_register_service({
      parent_engine: params[:parent_engine],
      type_path: 'certs',
      service_container_name: 'certs',
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
      domain_name:  params[:domain_name], #params[:default_domain]
      service_handle: params[:domain_name]
      }
    } )
  end

  def get_cert(params)
    certs_service = loadManagedService('certs')
    cert_name = 'engines' if cert_name == 'default'
      params[:common_name] = params[:cert_name] if params[:common_name].nil?
    actionator = get_service_actionator(certs_service, 'fetch_cert')
    certs_service.perform_action(actionator, params)
  end

end
