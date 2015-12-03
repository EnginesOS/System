module FirstRunDNS
  def apply_hostname(params)
    config_hash = {}
    config_hash[:service_name] = 'mgmt'
    config_hash[:configurator_name] = 'hostname'
    config_hash[:variables] = {}
    config_hash[:variables][:hostname] =  params[:hostname]
    config_hash[:variables][:domain_name] =  params[:default_domain]
    return true if @api.update_service_configuration(config_hash)
    return log_error_mesg('Hostname configurator ', config_hash)
  end

  def get_domain_params(params)
    domain_hash = {}
    domain_hash[:domain_name] = params[:default_domain]
    domain_hash[:self_hosted] = params[:default_domain_self_hosted]
    domain_hash[:internal_only] = params[:default_domain_internal_only]
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
    domain_hash[:default_domain] = @first_run_params[:default_domain]
    return false unless apply_hostname(@first_run_params)
    return log_error_mesg('Fail to set default domain ' + @api.last_error, domain_hash.to_s) unless @api.set_default_domain(domain_hash)
    return set_default_email_domain(domain_hash[:default_domain])

  end
  def validate_dns_params(params)
    return log_error_mesg('Can have empty default domain',params) if params[:default_domain].nil?
     return true
  end
end