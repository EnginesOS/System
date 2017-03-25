module EnginesSystemFlags

  @@EnginesSystemUpdatedFlag = '/opt/engines/run/system/flags/update_engines_run'
  @@EnginesSystemUpdatingFlag = '/opt/engines/run/system/flags/update_engines_running'
  @@SystemUpdatedFlag = '/opt/engines/run/system/flags/update_run'
  @@SystemUpdatingFlag = '/opt/engines/run/system/flags/update_running'
  @@EnginesSystemRebootNeededFlag = '/opt/engines/run/system/flags/reboot_required'
  @@SystemRebootingFlag = '/opt/engines/run/system/flags/engines_rebooting'
  @@EnginesUpdateStatusFile ='/opt/engines/run/system/flags/update_pending'
  @@FirstRunRan = '/opt/engines/run/system/flags/first_ran'
  def self.SystemRebootingFlag
    @@SystemRebootingFlag
  end

  def self.EnginesSystemRebootNeededFlag
    @@EnginesSystemRebootNeededFlag
  end

  def self.EnginesSystemUpdatedFlag
    @@EnginesSystemUpdatedFlag
  end

  def self.EnginesSystemUpdatingFlag
    @@EnginesSystemUpdatingFlag
  end

  def self.SystemUpdatingFlag
    @@SystemUpdatingFlag
  end

  def self.SystemUpdatedFlag
    @@SystemUpdatedFlag
  end

  def self.EnginesUpdateStatusFile
    @@EnginesUpdateStatusFile
  end

  def self.FirstRunRan
    @@FirstRunRan
  end

end