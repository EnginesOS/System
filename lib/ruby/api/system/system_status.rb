class SystemStatus
  def self.is_base_system_updating?
    File.exist?(SystemConfig.SystemUpdatingFlag)
  end

  # return [String] representing the address of public host interface (ie ifconfig eth0)
  def SystemStatus.get_base_host_ip
    ENV['CONTROL_IP'] #'control.engines.internal'
  end

  # return [String] representing the address docker interface
  def SystemStatus.get_docker_ip
    ENV['DOCKER_IP'] #'control.engines.internal'
  end

  def self.is_rebooting?
    File.exist?(SystemConfig.SystemRebootingFlag)
  end

  def self.needs_reboot?
    File.exist?(SystemConfig.EnginesSystemRebootNeededFlag)
  end

  def self.engines_system_has_updated?
    return File.delete(SystemConfig.EnginesSystemUpdatedFlag) if File.exist?(SystemConfig.EnginesSystemUpdatedFlag)
    false
  end

  def self.is_engines_system_updating?
    File.exist?(SystemConfig.EnginesSystemUpdatingFlag)
  end

  def self.base_system_has_updated?
    return File.delete(SystemConfig.SystemUpdatedFlag) if File.exist?(SystemConfig.SystemUpdatedFlag)
    false
  end

  def self.is_building?
    File.exist?(SystemConfig.BuildRunningParamsFile)
  end

  def self.did_build_fail?
    File.exist?(SystemConfig.BuildFailedFile)
  end

  def self.did_build_complete?
    File.exist?(SystemConfig.BuildBuiltFile)
  end

  def self.build_failed(params)
    param_file = File.new(SystemConfig.BuildFailedFile, 'w+')
    param_file.puts(params.to_yaml)
    param_file.close
    File.delete(SystemConfig.BuildRunningParamsFile) if File.exist?(SystemConfig.BuildRunningParamsFile)
  end

  def self.build_complete(params)
    param_file = File.new(SystemConfig.BuildBuiltFile, 'w+')
    param_file.puts(params.to_yaml)
    param_file.close
    File.delete(SystemConfig.BuildRunningParamsFile) if File.exist?(SystemConfig.BuildRunningParamsFile)
  end

  def self.build_starting(params)
    param_file = File.new(SystemConfig.BuildRunningParamsFile, 'w+')
    param_file.puts(params.to_yaml)
    param_file.close
    File.delete(SystemConfig.BuildFailedFile) if File.exist?(SystemConfig.BuildFailedFile)
  end

  def self.build_status
   {
    is_building:  SystemStatus.is_building?,
    did_build_fail:  SystemStatus.did_build_fail?
   }
  end

  def self.get_engines_system_release
    release = File.read(SystemConfig.ReleaseFile)
    release.strip!
  rescue StandardError => e
    SystemUtils.log_exception(e)
    return 'none'
  end

  # called by per session and post update
  def self.system_status
    {
      is_rebooting: SystemStatus.is_rebooting?,
      is_base_system_updating: SystemStatus.is_base_system_updating?,
      is_engines_system_updating: SystemStatus.is_engines_system_updating?,
      needs_reboot: SystemStatus.needs_reboot?,
      needs_engines_update: !self.is_engines_system_upto_date?,
      needs_base_update: !self.is_base_system_upto_date?
    }
  end

  # called by per session and post update
  def self.system_update_status
    {
      needs_engines_update:  !self.is_engines_system_upto_date?,
      needs_base_update:  !self.is_base_system_upto_date?
    }
  end

  def self.current_build_params
    unless File.exist?(SystemConfig.BuildRunningParamsFile)
      return  # SystemUtils.log_error_mesg("No ", SystemConfig.BuildRunningParamsFile)
    end
    param_file = File.new(SystemConfig.BuildRunningParamsFile, 'r')
    param_raw = param_file.read
    YAML.load(param_raw)
  end

  def self.last_build_params
    unless File.exist?(SystemConfig.BuildBuiltFile)
      raise EnginesException.new(error_hash('No last_build_params', SystemConfig.BuildBuiltFile))
    end
    param_file = File.new(SystemConfig.BuildBuiltFile, 'r')
    param_raw = param_file.read
    YAML.load(param_raw)
  end

  def self.last_build_failure_params
    unless File.exist?(SystemConfig.BuildFailedFile)
      raise EnginesException.new(error_hash('No last_build_failure_params ', SystemConfig.BuildFailedFile))
    end
    param_file = File.new(SystemConfig.BuildFailedFile, 'r')
    param_raw = param_file.read
    YAML.load(param_raw)
  end

  def self.is_remote_exception_logging?
     ! File.exist?(SystemConfig.NoRemoteExceptionLoggingFlagFile)
  end
  
  def self.is_base_system_upto_date?
    # FIX ME
    # in future check state of /opt/engines/run/system/flags/update_pending
     ! File.exists?('/opt/engines/run/system/flags/base_os_update_pending')
    #return true unless File.exists?('/opt/engines/run/system/flags/base_os_update_pending')
  end

  def self.is_engines_system_upto_date?
    if self.get_engines_system_release == 'current'
      SystemUtils.execute_command('/opt/engines/system/scripts/system/engines_system_update_status.sh')
    end
    ! File.exist?(SystemConfig.EnginesUpdateStatusFile)
  end

end
