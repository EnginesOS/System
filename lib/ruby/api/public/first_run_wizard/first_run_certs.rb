module FirstRunCerts
  def create_ca(ca_params)
    config_param = {}
    config_param[:service_name] = 'cert_auth'
    config_param[:configurator_name] = 'system_ca'
    config_param[:variables] = {}
    config_param[:variables][:country] = ca_params[:ssl_country]
    config_param[:variables][:state] = ca_params[:ssl_state]
    config_param[:variables][:city] = ca_params[:ssl_city]
    config_param[:variables][:organisation] = ca_params[:ssl_organisation_name]
    config_param[:variables][:person] = ca_params[:ssl_person_name]
    config_param[:variables][:domainname] = ca_params[:default_domain]
    return true if @api.update_service_configuration(config_param)
    return log_error_mesg('create_ca ', @api.last_error)
  end

  def create_default_cert(params)
    service_param = {}
    service_param[:parent_engine] = 'system'
    service_param[:type_path] = 'cert_auth'
    service_param[:service_container_name] = 'cert_auth'
    service_param[:container_type] = 'system'
    service_param[:persistent] = true
    service_param[:publisher_namespace] = 'EnginesSystem'
    service_param[:service_handle] = 'default_ssl_cert'
    service_param[:variables] = {}
    service_param[:variables][:cert_name] = 'engines'
    service_param[:variables][:country] = params[:ssl_country]
    service_param[:variables][:state] = params[:ssl_state]
    service_param[:variables][:city] = params[:ssl_city]
    service_param[:variables][:organisation] = params[:ssl_organisation_name]
    service_param[:variables][:person] = params[:ssl_person_name]
    service_param[:variables][:domainname] = params[:default_domain]
    service_param[:variables][:service_handle] = 'default_ssl_cert'
    return true if @api.create_and_register_service(service_param)
    return log_error_mesg('create_default_cert ', @api.last_error)
  end

  def setup_certs
    return false unless create_ca(@first_run_params)
    return false unless create_default_cert(@first_run_params)
    return log_error_mesg('create_default_cert ','/opt/engines/bin/install_ca.sh') unless SystemUtils.execute_command('/opt/engines/bin/install_ca.sh')
    return log_error_mesg('create_default_cert ','/opt/engines/bin/install_cert.sh engines') unless SystemUtils.execute_command('/opt/engines/bin/install_cert.sh engines')

    return true
  end

end