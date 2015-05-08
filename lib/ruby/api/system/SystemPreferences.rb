class SystemPreferences
  
  def initialize
      @preferences = YAML::load(File.read(SysConfig.SystemPreferencesFile))    
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
  save_preferences
  return EnginesOSapiResult.success(params[:default_site] ,:default_site)

rescue Exception=>e
  EnginesOSapiResult.failed(params[:default_site],e.to_s ,:default_site)
end
  
def get_default_site()     
 return @preferences[:default_site]
  rescue Exception=>e
    SystemUtils.log_exception(e)
    return "err"
end
    
def get_default_domain()   
  @preferences[:default_domain]
  rescue Exception=>e
   SystemUtils.log_exception(e)
   return "err"
 end  
    
def save_preferences
  File.rename( SysConfig.SystemPreferencesFile,   SysConfig.SystemPreferencesFile + ".bak")
  serialized_object = YAML::dump(self)
  f = File.new(SysConfig.SystemPreferencesFile,File::CREAT|File::TRUNC|File::RDWR, 0644)
  f.puts(serialized_object)
 f.close
  

  rescue Exception=>e
  SystemUtils.log_exception(e)
end
end