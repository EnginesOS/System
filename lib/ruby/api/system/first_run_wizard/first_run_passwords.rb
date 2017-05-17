module FirstRunPasswords
  def mysql_password_configurator(password)
    service_param = {}
    service_param[:service_name] = 'mysql_server'
    service_param[:configurator_name] = 'db_master_pass'
    service_param[:variables] = {}
    service_param[:variables][:db_master_pass] = password
    return true if @api.update_service_configuration(service_param)

  end

  def console_password_configurator(password)
    service_param = {}
    service_param[:service_name] = 'system'
    service_param[:configurator_name] = 'console_pass'
    service_param[:variables] = Hash.new
    service_param[:variables][:console_password] = password
    return true if @api.update_service_configuration(service_param)

  end

  def setup_ssh_key

    if @first_run_params.key?(:ssh_key) == true
      ssh_key_configurator(@first_run_params[:ssh_key])
    end
    true
  end

  def setup_system_password(password, email)
     @api.init_system_password(password, email)  
  end

  def ssh_key_configurator(key)
    service_param = {}
    service_param[:service_name] = 'system'
    service_param[:configurator_name] = 'ssh_master_key'
    service_param[:variables] = {}
    service_param[:variables][:ssh_master_key] = key
    return true if @api.update_service_configuration(service_param)

  end

  def set_passwords()
    return false unless mysql_password_configurator(@first_run_params[:mysql_password])
    return false unless console_password_configurator(@first_run_params[:console_password])
    return false unless setup_ssh_key
    true
  end
end