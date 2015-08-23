class SystemPreferences
  
  def initialize
    if File.exists?(SystemConfig.SystemPreferencesFile) == true
     @preferences = YAML::load(File.read(SystemConfig.SystemPreferencesFile))
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
    

    
def get_default_domain()
  p :get_default_domain   
  if @preferences.has_key?(:default_domain) == false
   return 'unset'
  end
    
  return @preferences[:default_domain]
  rescue Exception=>e
   SystemUtils.log_exception(e)
   return 'err'
 end  
    
def save_preferences
  if File.exists?(SystemConfig.SystemPreferencesFile) == true
    File.rename( SystemConfig.SystemPreferencesFile,   SystemConfig.SystemPreferencesFile + '.bak')
  end
  serialized_object = YAML::dump(@preferences)
  f = File.new(SystemConfig.SystemPreferencesFile,File::CREAT|File::TRUNC|File::RDWR, 0644)
  f.puts(serialized_object)
 f.close
  

  rescue Exception=>e
  SystemUtils.log_exception(e)
end
end