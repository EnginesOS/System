class SystemStatus
  
  def SystemStatus.is_base_system_updating?
     return File.exists?(SysConfig.SystemUpdatingFlag)
   end
 
   def SystemStatus.is_rebooting?
     File.exists?(SysConfig.SystemRebootingFlag)
   end
  

  def SystemStatus.needs_reboot?
     return File.exist?(SysConfig.EnginesSystemRebootNeededFlag)
   end
   
  def SystemStatus.engines_system_has_updated?
    if File.exists?(SysConfig.EnginesSystemUpdatedFlag)
      File.delete(SysConfig.EnginesSystemUpdatedFlag)
      return true
    end
    return false
  end

  def SystemStatus.is_engines_system_updating?
    return File.exists?(SysConfig.EnginesSystemUpdatingFlag)
  end

  def SystemStatus.base_system_has_updated?
    if File.exists?(SysConfig.SystemUpdatedFlag)
      File.delete(SysConfig.SystemUpdatedFlag)
      return true
    end
    return false
  end

  def SystemStatus.system_status
    result = Hash.new()
    result[:is_rebooting]=SystemStatus.is_rebooting?
    result[:is_base_system_updating]=SystemStatus.is_base_system_updating?
    result[:is_engines_system_updating] = SystemStatus.is_engines_system_updating?
    result[:needs_reboot]  = SystemStatus.needs_reboot?
      
    return result
    
  end
   
  
end