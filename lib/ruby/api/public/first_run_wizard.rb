class FirstRunWizard <ErrorsApi
  attr_reader  :error, :sucess
  def initialize(params)
    @sucess = false
    @first_run_params = params
  end

  def apply(api)
    @api = api
    p :applyin
    p @first_run_params
    return log_error_mesg('Fail to setup mysql password ', api.last_error) unless mysql_password_configurator(@first_run_params[:mysql_password])
    return log_error_mesg('Fail to setup console password ', api.last_error) unless console_password_configurator(@first_run_params[:console_password])
    domain_hash = get_domain_params(@first_run_params)
    return log_error_mesg('Fail to add domain ' + api.last_error, domain_hash) unless api.add_domain(domain_hash)
    domain_hash = {}
    domain_hash[:default_domain] = @first_run_params[:default_domain]
    return log_error_mesg('Fail to set default domain ' + api.last_error, domain_hash.to_s) unless api.set_default_domain(domain_hash)
    if @first_run_params.key?(:ssh_key) == true
      return log_error_mesg('Fail to setup ssh key ', api.last_error) unless ssh_key_configurator(@first_run_params[:ssh_key])
    end
    create_ca(@first_run_params)
    create_default_cert(@first_run_params)
    SystemUtils.execute_command('/opt/engines/bin/install_ca.sh')
    SystemUtils.execute_command('/opt/engines/bin/install_cert.sh engines')
    return log_error_mesg('Fail to setup set_default_email_domain ', api.last_error) unless set_default_email_domain(@first_run_params[:default_domain])
    @sucess = true
    mark_as_run
  end

  def set_default_email_domain(domain_name)
    service_param = {}
    service_param[:service_name] = 'smtp'
    service_param[:configurator_name] = 'default_domain'
    service_param[:variables] = {}
    service_param[:variables][:domain_name] = domain_name
    return true if @api.update_service_configuration(service_param)
    return log_error_mesg('smtp default domain configurator ', service_param)
  end

  def get_domain_params(params)
    domain_hash = {}
    domain_hash[:domain_name] = params[:default_domain]
    domain_hash[:self_hosted] = params[:default_domain_self_hosted]
    domain_hash[:internal_only] = params[:default_domain_internal_only]
    return domain_hash
  end

  def mysql_password_configurator(password)
    service_param = {}
    service_param[:service_name] = 'mysql_server'
    service_param[:configurator_name] = 'db_master_pass'
    service_param[:variables] = {}
    service_param[:variables][:db_master_pass] = password
    return true if @api.update_service_configuration(service_param)
    return log_error_mesg('mysql_password_configurator ', @api.last_error)
  end

  def console_password_configurator(password)
    service_param = {}
    service_param[:service_name] = 'mgmt'
    service_param[:configurator_name] = 'console_pass'
    service_param[:variables] = Hash.new
    service_param[:variables][:console_password] = password
    return true if @api.update_service_configuration(service_param)
    return log_error_mesg('console_password_configurator ', @api.last_error)
  end

  def ssh_key_configurator(key)
    service_param = {}
    service_param[:service_name] = 'mgmt'
    service_param[:configurator_name] = 'ssh_master_key'
    service_param[:variables] = {}
    service_param[:variables][:ssh_master_key] = key
    return true if @api.update_service_configuration(service_param)
    return log_error_mesg('ssh_key_configurator ', @api.last_error)
  end

  def mark_as_run
    f = File.new(SystemConfig.FirstRunRan, 'w')
    date = DateTime.now
    f.puts(date.to_s)
    f.close
  end

  def FirstRunWizard.required?
    return true if File.exist?(SystemConfig.FirstRunRan) == false
    return false
  end
  # FIXME: and put in it's own class or even service

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

  def create_default_cert (params)
    service_param = {}
    service_param[:parent_engine] = 'system'
    service_param[:type_path] = 'cert_auth'
    service_param[:service_container_name] = 'cert_auth'
    service_param[:container_type] = 'system'
    service_param[:persistant] = true
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
    return true if @api.attach_service(service_param)
    return  log_error_mesg('create_default_cert ', @api.last_error)
  end
end
