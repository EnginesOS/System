
module PublicApiConfig

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
       service_param[:service_name] = 'system'
       service_param[:configurator_name] = 'hostname'
       service_param[:variables] = {}
       service_param[:variables][:hostname] = hostname
       service_param[:variables][:domain_name] = get_default_domain
         STDERR.puts('set hostname params ' + service_param.to_s )
     @core_api.update_service_configuration(service_param)
     end
 
   def set_default_site(params)
     default_site_url = params
     default_site_url =  params[:default_site_url] unless  params.is_a?(String)
     service_param = {}
     service_param[:service_name] = 'nginx'
     service_param[:configurator_name] = 'default_site'
     service_param[:variables] = {}
     service_param[:variables][:default_site_url] = default_site_url
     @core_api.update_service_configuration(service_param)
   end
 
   def get_default_site()
     service_param = {}
     service_param[:service_name] = 'nginx'
     service_param[:configurator_name] = 'default_site'
     config_params = @core_api.retrieve_service_configuration(service_param)
     if config_params.is_a?(Hash) == true && config_params.key?(:variables) == true
       vars = config_params[:variables]
       return vars[:default_site_url] if vars.key?(:default_site_url)
     end
     return ''
   end
  def system_hostname
     @system_api.system_hostname
 end
 
  def enable_remote_exception_logging
     f = SystemConfig.NoRemoteExceptionLoggingFlagFile
     return File.delete(f) if File.exists?(f)
     return true
   rescue StandardError => e
     SystemUtils.log_exception(e)
   end
 
   def disable_remote_exception_logging
     FileUtils.touch(SystemConfig.NoRemoteExceptionLoggingFlagFile)
     return true
   rescue StandardError => e
     SystemUtils.log_exception(e)
   end
   
   def is_remote_exception_logging?     
      SystemStatus.is_remote_exception_logging?
     end
  
end
