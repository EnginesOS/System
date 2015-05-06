class SystemPreferences
  
  def initialize
      @preferences = YAML::load(File.read(SysConfig.SystemPreferencesFile))     
  end
  
def set_default_domain(params)
  @preferences[:default_domain] = params[:default_domain]
  save_preferences
end
    
def  set_default_site(params)
  @preferences[:default_site] = params[:default_site]
  save_preferences
end
  
def get_default_site()     
 return @preferences[:default_site]
end
    
def get_default_site()   
  @preferences[:default_domain]
 end  
    
def save_preferences
  File.rename( SysConfig.SystemPreferencesFile,   SysConfig.SystemPreferencesFile + ".bak")
  serialized_object = YAML::dump(self)
  f = File.new(SysConfig.SystemPreferencesFile,File::CREAT|File::TRUNC|File::RDWR, 0644)
  f.puts(serialized_object)
 f.close
  
end

end