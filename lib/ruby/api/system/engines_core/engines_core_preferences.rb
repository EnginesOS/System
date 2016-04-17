module EnginesCorePreferences
  def set_default_domain(params)
    SystemDebug.debug(SystemDebug.system,  :set_default_domain, params)
    preferences = SystemPreferences.new
    preferences.set_default_domain(params)
  end

  # WTF SystemPreferences ??
  def get_default_domain()
    preferences = SystemPreferences.new
    preferences.get_default_domain
  end
  def set_hostname(hostname)      
      service_param = {}
      service_param[:service_name] = 'mgmt'
      service_param[:configurator_name] = 'hostname'
      service_param[:vaiables] = {}
      service_param[:vaiables][:hostname] = hostname
    service_param[:vaiables][:domain_name] = get_default_domain
      update_service_configuration(service_param)
    end

  def set_default_site(params)
    default_site_url = params
    default_site_url =  params[:default_site_url] unless  params.is_a?(String)
    service_param = {}
    service_param[:service_name] = 'nginx'
    service_param[:configurator_name] = 'default_site'
    service_param[:vaiables] = {}
    service_param[:vaiables][:default_site_url] = default_site_url
    update_service_configuration(service_param)
  end

  def get_default_site()
    service_param = {}
    service_param[:service_name] = 'nginx'
    service_param[:configurator_name] = 'default_site'
    config_params = retrieve_service_configuration(service_param)
    if config_params.is_a?(Hash) == true && config_params.key?(:variables) == true
      vars = config_params[:variables]
      return vars[:default_site_url] if vars.key?(:default_site_url)
    end
    return ''
  end

end