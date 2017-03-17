module SystemSettings
  def enable_remote_exception_logging
    f = SystemConfig.NoRemoteExceptionLoggingFlagFile
    return File.delete(f) if File.exists?(f)
    true
  end

  def disable_remote_exception_logging
    FileUtils.touch(SystemConfig.NoRemoteExceptionLoggingFlagFile)
    true
  end

  def system_hostname
    res =  run_server_script('get_hostname')
    return res[:stdout].strip if res[:result] == 0
    log_error_mesg('fail to get hosthame ' + res[:stderr])
    'unknown'
  end

end