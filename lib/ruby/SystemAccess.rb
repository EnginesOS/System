class SystemAccess
  
  #This Class is the public face of the system
  #release etc
  
  def SystemAccess.release
    if File.exists?(SysConfig.ReleaseFile) == false
      return "current"
    end
    return File.read(SysConfig.ReleaseFile)        
  end
  
  def SystemAccess.mysql_host
    return "mysql.engines.internal"
  end
  
end