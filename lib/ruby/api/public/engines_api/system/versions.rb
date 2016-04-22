module SystemVersions
  
  def  get_engines_system_release
    SystemStatus.get_engines_system_release
  end
  
  def api_version
     return SystemConfig.api_version
   end
   
   def version_string
     SystemUtils.version
  
   end
   def system_version 
   
   SystemConfig.engines_system_version
 end 
 def get_os_release_data
  SystemUtils.get_os_release_data
 end
end