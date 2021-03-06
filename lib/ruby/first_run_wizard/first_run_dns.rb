class FirstRunWizard
  def apply_hostname(params)
 #   SystemDebug.debug(SystemDebug.first_run, 'setting hostname')
    core.update_service_configuration({
      service_name: 'system',
      configurator_name: 'hostname',
      variables: {
      hostname: params[:hostname],
      domain_name: params[:domain_name]
      }
    })
  #  SystemDebug.debug(SystemDebug.first_run, 'set hostname')
  end

  def get_domain_params(params)
    domain_hash = {
      domain_name: params[:domain_name]
    }
    if params[:networking] == 'zeroconf'
      domain_hash[:self_hosted] = true
      domain_hash[:internal_only] = true
      domain_hash[:domain_name] = 'local'
      params[:domain_name] = domain_hash[:domain_name]
    elsif params[:networking] == 'self_hosted_dns'
      domain_hash[:self_hosted] = true
      domain_hash[:internal_only] = true if params[:self_dns_local_only] == true
    elsif params[:networking] == 'external_dns'
      domain_hash[:self_hosted] = false
    elsif params[:networking] == 'dynamic_dns'
      domain_hash[:self_hosted] = false
      configure_dyndns_service(params)
    end
   # SystemDebug.debug(SystemDebug.first_run, 'domain_hash ' + domain_hash.to_s)
    domain_hash
  end

  def configure_dyndns_service(params)
    core.update_service_configuration( {
      service_name: 'dyndns',
      configurator_name: 'dyndns_settings',
      variables: {
      provider: params[:dynamic_dns_provider],
      domain_name: params[:domain_name],
      login: params[:dynamic_dns_username],
      password: params[:dynamic_dns_password]
      }
    })
    dyndns_service = core.loadManagedService('dyndns')
    dyndns_service.create_service
    return true if dyndns_service.is_running?
    dyndns_service.start_container
  end

  def set_default_email_domain(domain_name)
    core.update_service_configuration({
      service_name: 'smtp',
      configurator_name: 'default_domain',
      variables: {
      domain_name: domain_name,
      deliver_local: false,
      }
    })
  end

  def setup_dns
    domain_hash = get_domain_params(@first_run_params)
    return log_error_mesg('Fail to add nill domain ', domain_hash) if domain_hash[:domain_name].nil?
    core.add_domain_service(domain_hash)
   # SystemDebug.debug(SystemDebug.first_run, 'added Domain')
    apply_hostname(@first_run_params)
    core.set_default_domain(domain_hash)
   # SystemDebug.debug(SystemDebug.first_run, 'set_default_domain Domain')
    set_default_email_domain(domain_hash[:default_domain])
  #  SystemDebug.debug(SystemDebug.first_run, 'set_default_email_domain Domain')
    true
  end

  def validate_dns_params(params)
    if params[:domain_name].nil?
      log_error_mesg('Can have empty default domain',params)
    else
      true
    end
  end
end