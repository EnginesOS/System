module FirstRunDNS
  def apply_hostname(params)
    config_hash = {}
    config_hash[:service_name] = 'mgmt'
    config_hash[:configurator_name] = 'hostname'
    config_hash[:variables] = {}
    config_hash[:variables][:hostname] =  params[:hostname]
    config_hash[:variables][:domain_name] =  params[:domain_name]
    return true if @api.update_service_configuration(config_hash)
    return log_error_mesg('Hostname configurator ', config_hash)
  end

  def get_domain_params(params)
    domain_hash = {}
    domain_hash[:domain_name] = params[:domain_name]
    domain_hash[:type]  = params[:networking]
      #values for        params[:networking] 
      # zeroconf 
      # self_hosted_dns
      # external_dns
      # dynamic_dns
      # when dynamic_dns also dynamic_dns_provider dynamic_dns_username dynamic_dns_password use params[:domain_name] for hostname/dowmain tfor dyndns client
    if params[:networking] == 'zeroconf'
      domain_hash[:self_hosted] = true
      domain_hash[:internal_only] = true 
      domain_hash[:domain_name] = 'local'
      
    elsif params[:networking] == 'self_hosted_dns'
      domain_hash[:self_hosted] = true
      domain_hash[:internal_only] = true if params[:self_dns_local_only] == '1'
        
      elsif params[:networking] == 'external_dns'
      domain_hash[:self_hosted] = false
      elsif params[:networking] == 'dynamic_dns'
      domain_hash[:self_hosted] = false
      configure_dyndns_service(params)
        
    end
   
   def configure_dyndns_service(params)
     config_hash = {}
     config_hash[:service_name] = 'dyndns'
     config_hash[:configurator_name] = 'dyndns_settings'
     config_hash[:variables] = {}
     config_hash[:variables][:provider] = params[:dynamic_dns_provider]
     config_hash[:variables][:domain_name] = params[:domain_name]
     config_hash[:variables][:login] = params[:dynamic_dns_username]
     config_hash[:variables][:password] = params[:dynamic_dns_password]
     return true if @api.update_service_configuration(config_hash)
     return log_error_mesg('Failed to apply DynDNS ', config_hash)
   end
    
    return domain_hash
  end

  def set_default_email_domain(domain_name)
    config_hash = {}
    config_hash[:service_name] = 'smtp'
    config_hash[:configurator_name] = 'default_domain'
    config_hash[:variables] = {}
    config_hash[:variables][:domain_name] = domain_name
    return true if @api.update_service_configuration(config_hash)
    return log_error_mesg('smtp default domain configurator ', config_hash)
  end

  def setup_dns

    domain_hash = get_domain_params(@first_run_params)
    return log_error_mesg('Fail to add domain ' + @api.last_error, domain_hash) unless @api.add_domain_service(domain_hash)
    domain_hash = {}
    domain_hash[:default_domain] = @first_run_params[:domain_name]
    return false unless apply_hostname(@first_run_params)
    return log_error_mesg('Fail to set default domain ' + @api.last_error, domain_hash.to_s) unless @api.set_default_domain(domain_hash)
    return set_default_email_domain(domain_hash[:default_domain])

  end
  def validate_dns_params(params)
    return log_error_mesg('Can have empty default domain',params) if params[:default_domain].nil?
     return true
  end
end