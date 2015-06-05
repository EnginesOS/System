class SystemPreferences
  
  def initialize
    if File.exists?(SysConfig.SystemPreferencesFile) == true
     @preferences = YAML::load(File.read(SysConfig.SystemPreferencesFile))
  else
    @preferences = Hash.new
 end
    rescue Exception=>e
    SystemUtils.log_exception(e) 
  end
  
def set_default_domain(params)
  @preferences[:default_domain] = params[:default_domain]
  save_preferences
  return EnginesOSapiResult.success(params[:default_domain] ,:default_domain)
  rescue Exception=>e
      EnginesOSapiResult.failed(params[:default_domain],e.to_s ,:default_domain)
end
    
def  set_default_site(params)
  @preferences[:default_site] = params[:default_site]
  SystemUtils.debug_output( "save prefs", params)
  save_preferences
  return EnginesOSapiResult.success(params[:default_site] ,:default_site)

rescue Exception=>e
  EnginesOSapiResult.failed(params[:default_site],e.to_s ,:default_site)
end
  
def get_default_site()     
  if @preferences.has_key?(:default_site) == false
   return "unset"
  end
  
 return @preferences[:default_site]
   
  rescue Exception=>e
    SystemUtils.log_exception(e)
    return "err"
end
    
def get_default_domain()
  p :get_default_domain   
  if @preferences.has_key?(:default_domain) == false
   return "unset"
  end
    
  return @preferences[:default_domain]
  rescue Exception=>e
   SystemUtils.log_exception(e)
   return "err"
 end  
    
def save_preferences
  if File.exists?(SysConfig.SystemPreferencesFile) == true
    File.rename( SysConfig.SystemPreferencesFile,   SysConfig.SystemPreferencesFile + ".bak")
  end
  serialized_object = YAML::dump(@preferences)
  f = File.new(SysConfig.SystemPreferencesFile,File::CREAT|File::TRUNC|File::RDWR, 0644)
  f.puts(serialized_object)
 f.close
  

  rescue Exception=>e
  SystemUtils.log_exception(e)
end
end