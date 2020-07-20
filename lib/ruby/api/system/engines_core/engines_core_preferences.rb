module EnginesCorePreferences
  def set_default_domain(params)
    #SystemDebug.debug(SystemDebug.system, :set_default_domain, params)
    preferences = SystemPreferences.new
    preferences.set_default_domain(params)
  end

  # WTF SystemPreferences ??
  def default_domain
    preferences = SystemPreferences.new
    preferences.default_domain
  end

  def set_hostname(hostname)
    update_service_configuration( {
      service_name: 'system',
      configurator_name: 'hostname',
      variables: {
      hostname: hostname,
      domain_name: default_domain
      }
    })
  end

  def set_default_site(params)
    default_site = params
    default_site =  params[:default_site] unless  params.is_a?(String)
    update_service_configuration({
      service_name: 'wap',
      configurator_name: 'default_site',
      variables: {
      default_site: default_site
      }})
  end

  def get_default_site()
    config_params = retrieve_service_configuration( {
      service_name: 'wap',
      configurator_name: 'default_site'
    })
    if config_params.is_a?(Hash) == true && config_params.key?(:variables) == true
      vars = config_params[:variables]
      if vars.key?(:default_site)
        vars[:default_site]
      end
    else
      nil
    end
  end
end