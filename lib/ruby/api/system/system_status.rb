class SystemStatus
  def self.is_base_system_updating?
    return true unless File.exist?(SystemConfig.SystemUpdatingFlag)
    false
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
  rescue StandardError => e
    SystemUtils.log_exception(e)
    return {}
  end

  def self.build_complete(params)

    param_file = File.new(SystemConfig.BuildBuiltFile, 'w+')
    param_file.puts(params.to_yaml)
    param_file.close
    File.delete(SystemConfig.BuildRunningParamsFile) if File.exist?(SystemConfig.BuildRunningParamsFile)
  rescue StandardError => e
    SystemUtils.log_exception(e)
    return {}
  end

  def self.build_starting(params)
    param_file = File.new(SystemConfig.BuildRunningParamsFile, 'w+')
    param_file.puts(params.to_yaml)
    param_file.close
    File.delete(SystemConfig.BuildFailedFile) if File.exist?(SystemConfig.BuildFailedFile)
    #  File.delete(SystemConfig.BuildBuiltFile) if File.exist?(SystemConfig.BuildBuiltFile)
  rescue StandardError => e
    SystemUtils.log_exception(e)

  end

  def self.build_status
    result = {}
    result[:is_building] = SystemStatus.is_building?
    result[:did_build_fail] = SystemStatus.did_build_fail?
    result
  rescue StandardError => e
    SystemUtils.log_exception(e)

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
    is_rebooting:  SystemStatus.is_rebooting?,
    is_base_system_updating:  SystemStatus.is_base_system_updating?,
    is_engines_system_updating:  SystemStatus.is_engines_system_updating?,
    needs_reboot:  SystemStatus.needs_reboot?,
    needs_engines_update:  self.is_engines_system_upto_date?,
    needs_base_update:  self.is_base_system_upto_date?
  }

  rescue StandardError => e
    SystemUtils.log_exception(e)

  end

  # called by per session and post update
  def self.system_update_status
    {engines_system:  self.is_engines_system_upto_date?,
    base_os:  self.is_base_system_upto_date?
  }
  rescue StandardError => e
    SystemUtils.log_exception(e)

  end

  def self.current_build_params
    unless File.exist?(SystemConfig.BuildRunningParamsFile)
      return {} # SystemUtils.log_error_mesg("No ", SystemConfig.BuildRunningParamsFile)

    end
    param_file = File.new(SystemConfig.BuildRunningParamsFile, 'r')
    param_raw = param_file.read
    YAML.load(param_raw)
  rescue StandardError => e
    SystemUtils.log_exception(e)

  end

  def self.last_build_params
    unless File.exist?(SystemConfig.BuildBuiltFile)
      SystemUtils.log_error_mesg('No  last_build_params', SystemConfig.BuildBuiltFile)
      return {}
    end
    param_file = File.new(SystemConfig.BuildBuiltFile, 'r')
    param_raw = param_file.read
    YAML.load(param_raw)
  rescue StandardError => e
    SystemUtils.log_exception(e)

  end

  def self.last_build_failure_params
    unless File.exist?(SystemConfig.BuildFailedFile)
      SystemUtils.log_error_mesg('No last_build_failure_params ', SystemConfig.BuildFailedFile)
      return {}
    end
    param_file = File.new(SystemConfig.BuildFailedFile, 'r')
    param_raw = param_file.read
    YAML.load(param_raw)
  rescue StandardError => e
    SystemUtils.log_exception(e)

  end

  def self.is_remote_exception_logging?
    return true unless File.exist?(SystemConfig.NoRemoteExceptionLoggingFlagFile)
    false
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  #  def self.get_system_load_info
  #    ret_val = {}
  #    loadavg_info = File.read('/proc/loadavg')
  #
  #    values = loadavg_info.split(' ')
  #    ret_val[:one] = values[0]
  #    ret_val[:five] = values[1]
  #    ret_val[:fifteen] = values[2]
  #    run_idle = values[3].split('/')
  #    ret_val[:running] = run_idle[0]
  #    ret_val[:idle] = run_idle[1]
  #    ret_val
  #  rescue StandardError => e
  #    SystemUtils.log_exception(e)
  #    ret_val[:one] = -1
  #    ret_val[:five] = -1
  #    ret_val[:fifteen] = -1
  #    ret_val[:running] = -1
  #    ret_val[:idle] = -1
  #    return ret_val
  #  rescue StandardError => e
  #    SystemUtils.log_exception(e)
  #  end

  def self.is_base_system_upto_date?
    # FIX ME
    # in future check state of /opt/engines/run/system/flags/update_pending
    return  File.exists?('/opt/engines/run/system/flags/base_os_update_pending')

    #result = run_server_script('deb_update_status')
    # result = SystemUtils.execute_command('/opt/engines/system/scripts/system/engines_system_update_status.sh')

    #  return false
  rescue StandardError => e
    SystemUtils.log_exception(e)

  end

  def self.is_engines_system_upto_date?
   
    if self.get_engines_system_release == 'current'   
      result = SystemUtils.execute_command('/opt/engines/system/scripts/system/engines_system_update_status.sh')   
      return true if result[:result] == 0
      false
    end
    return true unless File.exist?(SystemConfig.EnginesUpdateStatusFile)
    false
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

end
