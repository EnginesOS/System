module FirstRunCerts
  def create_ca(ca_params)
    true if @api.update_service_configuration({
      service_name: 'certs',
      configurator_name: 'system_ca',
      variables: {
      country: ca_params[:ssl_country],
      state: ca_params[:ssl_state],
      city: ca_params[:ssl_city],
      organisation: ca_params[:ssl_organisation_name],
      person: ca_params[:ssl_person_name],
      domain_name: ca_params[:domain_name]
      },
    })
  end

  def create_default_cert(params)
    service_param = {
      parent_engine: 'system',
      type_path: 'certs',
      service_container_name: 'certs',
      container_type: 'system_service',
      persistent: true,
      publisher_namespace: 'EnginesSystem',
      service_handle: 'default_ssl_cert',
      variables: {
      wild: 'true',
      install_target: 'default',
      cert_name: 'engines',
      country: params[:ssl_country],
      state: params[:ssl_state],
      city: params[:ssl_city],
      organisation: params[:ssl_organisation_name],
      person: params[:ssl_person_name],
      domain_name: params[:domain_name], #params[:default_domain]
      service_handle: 'default_ssl_cert'
      },
    }
    @api.create_and_register_service(service_param)
  end

  def set_wap_cert(def_domain)
    @api.perform_service_action('certs', 'set_default', {
    install_target: 'services/wap',
     cert_name: 'system_services/system/' + def_domain,
     cert_type: 'generated' 
  })
   
  end
  def setup_certs
    create_ca(@first_run_params)
    create_default_cert(@first_run_params)
    set_wap_cert(@first_run_params[:domain_name])
    return log_error_mesg('create_default_cert ','/opt/engines/bin/install_ca.sh') unless SystemUtils.execute_command('/opt/engines/system/scripts/ssh/install_ca.sh')
    #return log_error_mesg('create_default_cert ','/opt/engines/bin/install_cert.sh engines') unless SystemUtils.execute_command('/opt/engines/system/scripts/ssh/install_cert.sh engines')
    true
  end

end