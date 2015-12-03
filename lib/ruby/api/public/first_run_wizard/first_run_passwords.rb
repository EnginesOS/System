module FirstRunPasswords
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

  def setup_ssh_key

    if @first_run_params.key?(:ssh_key) == true
      return log_error_mesg('Fail to setup ssh key ', api.last_error) unless ssh_key_configurator(@first_run_params[:ssh_key])
    end
    return true
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

  def set_passwords()
    return false unless mysql_password_configurator(@first_run_params[:mysql_password])
    return false unless console_password_configurator(@first_run_params[:console_password])
    return false unless setup_ssh_key
    return true
  end
end