module PublicApiConfig
  def set_default_domain(params)
    SystemDebug.debug(SystemDebug.system,  :set_default_domain, params)
    SystemDebug.debug(SystemDebug.first_run, 'set_default_domain Domain')
    preferences = SystemPreferences.new
    preferences.set_default_domain(params)
  end

  # WTF SystemPreferences ??
  def get_default_domain()
    preferences = SystemPreferences.new
    preferences.get_default_domain
  end

  def set_hostname(hostname)
    @core_api.update_service_configuration( {
      service_name: 'system',
      configurator_name: 'hostname',
      variables: {
      hostname: hostname,
      domain_name: get_default_domain
      }})
  end

  def set_default_site(params)
    default_site_url = params
    default_site_url =  params[:default_site_url] unless  params.is_a?(String)
    @core_api.update_service_configuration({
      service_name: 'wap',
      configurator_name: 'default_site',
      variables: {
      default_site_url: default_site_url
      }
    })
  end

  def get_default_site()
    config_params = @core_api.retrieve_service_configuration(
    {
      service_name:  'wap',
      configurator_name: 'default_site'
    })
    if config_params.is_a?(Hash) == true && config_params.key?(:variables) == true
      vars = config_params[:variables]
      vars[:default_site_url] if vars.key?(:default_site_url)
    else
      ''
    end
  end

  def system_hostname
    @system_api.system_hostname
  end

  # FIXME should use System
  def enable_remote_exception_logging
    @core_api.enable_remote_exception_logging
  end

  # FIXME should use System
  def disable_remote_exception_logging
    @core_api.disable_remote_exception_logging
  end

  # FIXME should use System
  def is_remote_exception_logging?
    SystemStatus.is_remote_exception_logging?
  end

end
