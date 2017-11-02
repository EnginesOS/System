module EnginesSystemFlags

  @@EnginesSystemUpdatedFlag = '/opt/engines/run/system/flags/update_engines_run'
  @@EnginesSystemUpdatingFlag = '/opt/engines/run/system/flags/update_engines_running'
  @@SystemUpdatedFlag = '/opt/engines/run/system/flags/update_run'
  @@SystemUpdatingFlag = '/opt/engines/run/system/flags/update_running'
  @@EnginesSystemRebootNeededFlag = '/opt/engines/run/system/flags/reboot_required'
  @@SystemRebootingFlag = '/opt/engines/run/system/flags/engines_rebooting'
  @@EnginesUpdateStatusFile ='/opt/engines/run/system/flags/update_pending'
  @@FirstRunRan = '/opt/engines/run/system/flags/first_ran'
  @@EngineSystemIsStartingFile =  '/opt/engines/run/system/flags/system_starting'
  @@EngineSystemIsStartedFile =  '/opt/engines/run/system/flags/system_started'
  
  def SystemConfig.is_system_starting?
    File.exists?(@@EngineSystemIsStartingFile)
  end
  
  def SystemConfig.SystemRebootingFlag
    @@SystemRebootingFlag
  end

  def SystemConfig.EnginesSystemRebootNeededFlag
    @@EnginesSystemRebootNeededFlag
  end

  def SystemConfig.EnginesSystemUpdatedFlag
    @@EnginesSystemUpdatedFlag
  end

  def SystemConfig.EnginesSystemUpdatingFlag
    @@EnginesSystemUpdatingFlag
  end

  def SystemConfig.SystemUpdatingFlag
    @@SystemUpdatingFlag
  end

  def SystemConfig.SystemUpdatedFlag
    @@SystemUpdatedFlag
  end

  def SystemConfig.EnginesUpdateStatusFile
    @@EnginesUpdateStatusFile
  end

  def SystemConfig.FirstRunRan
    @@FirstRunRan
  end

end