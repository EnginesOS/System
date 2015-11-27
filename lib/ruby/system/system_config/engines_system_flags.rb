module EnginesSystemFlags

  @@EnginesSystemUpdatedFlag = '/opt/engines/run/system/flags/update_engines_run'
  @@EnginesSystemUpdatingFlag = '/opt/engines/run/system/flags/update_engines_running'
  @@SystemUpdatedFlag = '/opt/engines/run/system/flags/update_run'
  @@SystemUpdatingFlag = '/opt/engines/run/system/flags/update_running'
  @@EnginesSystemRebootNeededFlag = '/opt/engines/run/system/flags/reboot_required'
  @@SystemRebootingFlag = '/opt/engines/run/system/flags/engines_rebooting'
  @@EnginesUpdateStatusFile ='/opt/engines/run/system/flags/update_pending'
  @@FirstRunRan = '/opt/engines/run/system/flags/first_ran'
  def SystemConfig.SystemRebootingFlag
    return @@SystemRebootingFlag
  end

  def SystemConfig.EnginesSystemRebootNeededFlag
    return @@EnginesSystemRebootNeededFlag
  end

  def SystemConfig.EnginesSystemUpdatedFlag
    return   @@EnginesSystemUpdatedFlag
  end

  def SystemConfig.EnginesSystemUpdatingFlag
    return   @@EnginesSystemUpdatingFlag
  end

  def SystemConfig.SystemUpdatingFlag
    return   @@SystemUpdatingFlag
  end

  def SystemConfig.SystemUpdatedFlag
    return   @@SystemUpdatedFlag
  end

  def self.EnginesUpdateStatusFile
    @@EnginesUpdateStatusFile
  end

  def SystemConfig.FirstRunRan
    return @@FirstRunRan
  end

end