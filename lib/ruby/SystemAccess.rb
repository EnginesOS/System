class SystemAccess
  
  #This Class is the public face of the system
  #release etc
  
  def release
    if File.exists?(SysConfig.ReleaseFile) == false
      return "current"
    end
    return File.read(SysConfig.ReleaseFile)        
  end
  
  def mysql_host
    return SysConfig.DBHost
  end
  
end