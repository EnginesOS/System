class FirstRunWizard
  attr_reader  :error,:sucess
  def initialize(params)
    @sucess = false
    @error = "None"
    @first_run_params = params

  end

  def apply(api)

    if mysql_password_configurator(@first_run_params[:mysql_password]) == false
      @error="Fail to setup mysql password " + api.last_error()
      return false
    end

    if ssh_password_configurator(@first_run_params[:ssh_password]) == false
      @error="Fail to setup ssh password " + api.last_error()
      return false
    end

    domain_hash = get_domain_params(@first_run_params)
    if api.add_domain(domain_hash) == false
      @error="Fail to add domain " + api.last_error() + " " + domain_hash
      return false
    end
   
    if api.set_default_domain(domain_hash)  == false
      @error="Fail to set default domain " + api.last_error() + " " + domain_hash
      return false
    end

    if @first_run_params.has_key?(:ssh_key) == true
      if ssh_key_configurator(@first_run_params[:ssh_key]) == false
        @error="Fail to setup ssh key " + api.last_error()
        return false
      end
    end
    #
    #
    #    create_ca(@first_run_params[])
    #
    #    create_default_cert
    #
    #    restart_ssl_dependant_services
    @sucess=true
    mark_as_run
  end

  def get_domain_params(params)
    domain_hash = Hash.new()
    domain_hash[:default_domain]=params[:default_domain]
    domain_hash[:self_hosted]
    domain_hash[:internal_only]
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
    return  update_service_configuration(service_param)
  end

  def ssh_password_configurator(passwd)
    service_param = Hash.new
    service_param[:service_name] = "mgmt"
    service_param[:configurator_name] = "ssh_master_pass"
    service_param[:variables] = Hash.new
    service_param[:variables][:ssh_master_pass] = password
    return  update_service_configuration(service_param)
  end

  def ssh_key_configurator(key)
    service_param = Hash.new
    service_param[:service_name] = "mgmt"
    service_param[:configurator_name] = "ssh_master_key"
    service_param[:variables] = Hash.new
    service_param[:variables][:ssh_master_key] = key
    return  update_service_configuration(service_param)

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
    
  
  end

  def create_default_cert
   
  end
end