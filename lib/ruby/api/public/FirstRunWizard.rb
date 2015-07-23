class FirstRunWizard
  attr_reader  :error,:sucess
  def initialize(params)
    @sucess = false
    @error = "None"
    @first_run_params = params

  end

  def apply(api)
  @api = api
  
    if mysql_password_configurator(@first_run_params[:mysql_password]) == false
      @error="Fail to setup mysql password " + api.last_error()
      return false
    end

#    if ssh_password_configurator(@first_run_params[:ssh_password]) == false
#      @error="Fail to setup ssh password " + api.last_error()
#      return false
#    end

    domain_hash = get_domain_params(@first_run_params)
    if api.add_domain(domain_hash) == false
      @error="Fail to add domain " + api.last_error() + " " + domain_hash.to_s
      return false
    end
   
    if api.set_default_domain(domain_hash)  == false
      @error="Fail to set default domain " + api.last_error() + " " + domain_hash.to_s
      return false
    end

    if @first_run_params.has_key?(:ssh_key) == true
      if ssh_key_configurator(@first_run_params[:ssh_key]) == false
        @error="Fail to setup ssh key " + api.last_error()
        return false
      end
    end
    
    
        create_ca(@first_run_params[])
    #
    #    create_default_cert
    #
    #    restart_ssl_dependant_services
    @sucess=true
    mark_as_run
  end

  def get_domain_params(params)
    domain_hash = Hash.new()
    domain_hash[:domain_name]=params[:default_domain]
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
    return  @api.update_service_configuration(service_param)
  end

  def ssh_password_configurator(password)
    service_param = Hash.new
    service_param[:service_name] = "mgmt"
    service_param[:configurator_name] = "ssh_master_pass"
    service_param[:variables] = Hash.new
    service_param[:variables][:ssh_master_pass] = password
    return  @api.update_service_configuration(service_param)
  end

  def ssh_key_configurator(key)
    service_param = Hash.new
    service_param[:service_name] = "mgmt"
    service_param[:configurator_name] = "ssh_master_key"
    service_param[:variables] = Hash.new
    service_param[:variables][:ssh_master_key] = key
    return  @api.update_service_configuration(service_param)

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
    service_param = Hash.new
      service_param[:service_name] = "cert_auth"
      service_param[:configurator_name] = "system_ca"
      service_param[:variables] = Hash.new
#      service_param[:variables][:cert_name] = "engines"
    service_param[:variables][:country] = ca_params[:ssl_country]
    service_param[:variables][:state]= ca_params[:ssl_state]
    service_param[:variables][:city]= ca_params[:ssl_city]
    service_param[:variables][:organisation]= ca_params[:ssl_organisation_name]
    service_param[:variables][:person]= ca_params[:ssl_person_name]
    service_param[:variables][:domainname]= ca_params[:default_domain]
      
    return  @api.update_service_configuration(service_param)

  
  end

  def create_default_cert (params)
    service_param = Hash.new
    service_param[:parent_engine] = "system"
    service_param[:type_path] = "cert_auth"
    service_param[:service_container_name] = "cert_auth"
     service_param[:container_type] = "system"

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
         
    if   @api.attach_service(service_hash) == true
        @api.register_persistant_service(service_hash)
        return true
      end
  end
  
end