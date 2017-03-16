module Certificates
  def upload_ssl_certificate(params)

    certs_service = loadManagedService('cert_auth')
    return certs_service if certs_service.is_a?(EnginesError)

    certs_service.perform_action('import_cert',params[:domain_name], params[:certificate] + params[:key])
 
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
 
  end

  def get_system_ca
    certs_service = loadManagedService('cert_auth')
    return certs_service if certs_service.is_a?(EnginesError)
    certs_service.perform_action('system_ca',nil)
  
  end
  
  
  def generate_cert(params)
    certs_service = loadManagedService('cert_auth')   
    return certs_service if certs_service.is_a?(EnginesError)
   c = certs_service.perform_action('fetch_cert', params[:variables][:domainname])
     if c == "a_cert"
       #bail if not overrite
       return false
     end 
    params[:type_path] = 'cert_auth'
    params[:service_container_name] = 'cert_auth'
    params[:persistent] = true
    params[:publisher_namespace] = 'EnginesSystem'
      
   
 
#    service_param[:parent_engine] = 'system'
#      service_param[:service_handle] = 'default_ssl_cert'
#      service_param[:variables] = {}
#      service_param[:variables][:wild] = 'yes'
#      service_param[:variables][:cert_name] = 'engines'
#      service_param[:variables][:country] = params[:ssl_country]
#      service_param[:variables][:state] = params[:ssl_state]
#      service_param[:variables][:city] = params[:ssl_city]
#      service_param[:variables][:organisation] = params[:ssl_organisation_name]
#      service_param[:variables][:person] = params[:ssl_person_name]
#      service_param[:variables][:domainname] =  params[:domain_name] #params[:default_domain]
#      service_param[:variables][:service_handle] = 'default_ssl_cert'
        @engines_api.create_and_register_service(params)
  
  
  end
  def get_cert(domain_name)
    certs_service = loadManagedService('cert_auth')

    return certs_service if certs_service.is_a?(EnginesError)

    domain_name = 'engines' if domain_name == 'default'
    certs_service.perform_action('fetch_cert', domain_name)
  

  end

end