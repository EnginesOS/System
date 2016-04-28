module PublicApiBuilder
  
  def last_build_params
    SystemStatus.last_build_params
  end
  
  def last_build_log
    return "none" unless File.exists?(SystemConfig.BuildOutputFile)
    File.read(SystemConfig.BuildOutputFile)
    
  end
  
  def build_status
    SystemStatus.build_status
end

end
