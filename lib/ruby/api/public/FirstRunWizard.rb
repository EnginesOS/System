class FirstRunWizard
  attr_reader  :error,:sucess
  def initialize(params)
    @sucess = false
    @error = "None"
    @first_run_params = params

  end

  def apply(api)
  @api = api
  p :applyin
  p @first_run_params 
    if mysql_password_configurator(@first_run_params[:mysql_password]) == false
      log_error("Fail to setup mysql password " + api.last_error())
      return false
    end

   if console_password_configurator(@first_run_params[:console_password]) == false
     log_error("Fail to setup console password " + api.last_error())
      return false
    end

    domain_hash = get_domain_params(@first_run_params)
    if api.add_domain(domain_hash) == false
      log_error("Fail to add domain " + api.last_error() + " " + domain_hash.to_s)
      return false
    end
   domain_hash = Hash.new()
    domain_hash[:domain_name]=params[:default_domain]
    if api.set_default_domain(domain_hash)  == false
      log_error("Fail to set default domain " + api.last_error() + " " + domain_hash.to_s)
      return false
    end

    if @first_run_params.has_key?(:ssh_key) == true
      if ssh_key_configurator(@first_run_params[:ssh_key]) == false
        log_error("Fail to setup ssh key " + api.last_error())
        return false
      end
    end
    
    
        create_ca(@first_run_params)
    #
        create_default_cert(@first_run_params)
    SystemUtils.execute_command("/opt/engines/bin/install_ca.sh")
    SystemUtils.execute_command("/opt/engines/bin/install_cert.sh engines")
    #@api.install_refresh_ca
    #@api.install_default_cert
    #  happens above  restart_ssl_dependant_services
    @sucess=true
    mark_as_run
  end

  def get_domain_params(params)
    domain_hash = Hash.new()
 
    domain_hash[:default_domain]=params[:default_domain]
    domain_hash[:self_hosted] = params[:default_domain_self_hosted]
    domain_hash[:internal_only] = params[:default_domain_internal_only]
    #self host
    #internal only
    return domain_hash
  end

  def mysql_password_configurator(password)
    service_param = Hash.new
    service_param[:service_name] = "mysql_server"
    service_param[:configurator_name] = "db_master_pass"
    service_param[:variables] = Hash.new
    service_param[:variables][:db_master_pass] = password
    if  @api.update_service_configuration(service_param) == true
      return true
    else
      log_error("mysql_password_configurator " + @api.last_error.to_s)
      return false
    end
  end

  def console_password_configurator(password)
    service_param = Hash.new
    service_param[:service_name] = "mgmt"
    service_param[:configurator_name] = "console_pass"
    service_param[:variables] = Hash.new
    service_param[:variables][:console_password] = password
          
    if @api.update_service_configuration(service_param) == true
      return true
    else
      log_error("console_password_configurator " + @api.last_error.to_s)
      return false
    end
end

  
  def log_error(err)
    p "Error with first run " +err
    @error = err
  end

  def ssh_key_configurator(key)
    service_param = Hash.new
    service_param[:service_name] = "mgmt"
    service_param[:configurator_name] = "ssh_master_key"
    service_param[:variables] = Hash.new
    service_param[:variables][:ssh_master_key] = key
    if   @api.update_service_configuration(service_param) == true
      return true
    else
      log_error("ssh_key_configurator " + @api.last_error.to_s)
      return false
    end

  end

  def mark_as_run
    f = File.new(SysConfig.FirstRunRan,"w")
    date = DateTime.now
    f.puts(date.to_s)
    f.close
  end


  def FirstRunWizard.required?
    if File.exists?(SysConfig.FirstRunRan) ==false
      return true
    end
    return false
  end

  #FIXME and put in it's own class or even service
 
  def create_ca(ca_params)
    config_param = Hash.new
    config_param[:service_name] = "cert_auth"
    config_param[:configurator_name] = "system_ca"
    config_param[:variables] = Hash.new
#      service_param[:variables][:cert_name] = "engines"
    config_param[:variables][:country] = ca_params[:ssl_country]
    config_param[:variables][:state]= ca_params[:ssl_state]
    config_param[:variables][:city]= ca_params[:ssl_city]
    config_param[:variables][:organisation]= ca_params[:ssl_organisation_name]
    config_param[:variables][:person]= ca_params[:ssl_person_name]
    config_param[:variables][:domainname]= ca_params[:default_domain]
      
    if  @api.update_service_configuration(config_param)  == true
      return true
    else
      log_error("create_ca " + @api.last_error.to_s)
      return false
    end

  end

  def create_default_cert (params)
    service_param = Hash.new
    service_param[:parent_engine] = "system"
    service_param[:type_path] = "cert_auth"
    service_param[:service_container_name] = "cert_auth"
     service_param[:container_type] = "system"
    service_param[:persistant]=true
       service_param[:publisher_namespace] = "EnginesSystem"
       service_param[:service_handle] ="default_ssl_cert"
       service_param[:variables] = Hash.new
       service_param[:variables][:cert_name] = "engines"
       service_param[:variables][:country] = params[:ssl_country]
       service_param[:variables][:state]= params[:ssl_state]
       service_param[:variables][:city]= params[:ssl_city]
       service_param[:variables][:organisation]= params[:ssl_organisation_name]
       service_param[:variables][:person]= params[:ssl_person_name]
       service_param[:variables][:domainname]= params[:default_domain]
    service_param[:variables][:service_handle] ="default_ssl_cert"
    if   @api.attach_service(service_param) == true
      return true
    else
      log_error("create_default_cert " + @api.last_error.to_s)
      return false
    end
  end
  
end