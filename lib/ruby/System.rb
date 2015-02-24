class System
  
  #This Class is the public face of the system
  #release etc
  
  def System.release
    if File.exists?(SysConfig.ReleaseFile) == false
      return "current"
    end
    return File.read(SysConfig.ReleaseFile)        
  end
  
  
end