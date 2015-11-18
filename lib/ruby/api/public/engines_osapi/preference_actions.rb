module PreferenceActions
  # @return EngineOSapiResult
   # set the default Domain used by the system in creating new engines and for services that use web
   def set_default_domain(params)
     return success('Preferences', 'Set Default Domain') if @core_api.set_default_domain(params)
     failed('Preferences', @core_api.last_error, 'Set Default Domain')
   end
   

  def enable_remote_exception_logging
    return  success('System','Enable Remote Exception Logging') if @core_api.enable_remote_exception_logging
    failed('Preferences', @core_api.last_error, 'Enable Remote Exception Logging')
  end
  def disable_remote_exception_logging
    return  success('System','disable Remote Exception Logging') if @core_api.disable_remote_exception_logging
    failed('System', @core_api.last_error, 'disable Remote Exception Logging')
  end
    
    # @return boolean
    #   #set the site that unmatched host names are redirected, ie wild card host. Defaults to control panel login
    def set_default_site(params)
      return success('Preferences', 'Set Default Site') if @core_api.set_default_site(params)
      failed('Preferences', @core_api.last_error, 'Set Default Site')
    end
  
    # @return String
    # get the site that unmatched host names are redirected, ie wild card host. Defaults to control panel login
    def get_default_site
      @core_api.get_default_site
    end
    
end