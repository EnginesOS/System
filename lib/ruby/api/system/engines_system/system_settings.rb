module SystemSettings
  def enable_remote_exception_logging
    f = SystemConfig.NoRemoteExceptionLoggingFlagFile
    return File.delete(f) if File.exists?(f)
    return true
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def disable_remote_exception_logging
    FileUtils.touch(SystemConfig.NoRemoteExceptionLoggingFlagFile)
    return true
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end
  
 def system_hostname  
      res =  run_server_script('get_hostname')     
   return res[:stdout] if res[:result] == 0
   log_error_mesg('fail to get hosthame ' + res[:stderr])  
   return 'unknown'
 end
end