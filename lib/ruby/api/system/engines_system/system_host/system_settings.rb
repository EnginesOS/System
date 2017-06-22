module SystemSettings
  def enable_remote_exception_logging
    f = SystemConfig.NoRemoteExceptionLoggingFlagFile
    File.delete(f) if File.exists?(f)    
  end

  def disable_remote_exception_logging
    FileUtils.touch(SystemConfig.NoRemoteExceptionLoggingFlagFile)
  end

  def system_hostname
    res = run_server_script('get_hostname')
    if res[:result] == 0
      res[:stdout].strip
    else
      log_error_mesg('fail to get hosthame ' + res[:stderr])
      'unknown'
    end
  end

end