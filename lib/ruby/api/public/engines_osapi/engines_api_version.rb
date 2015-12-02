module EngOSapiVersion
  def api_version
    return SystemConfig.api_version
  end
  
  def version_string
    SystemUtils.version
 
  end
  def system_version 
  
  SystemConfig.engines_system_version
end 
  
end