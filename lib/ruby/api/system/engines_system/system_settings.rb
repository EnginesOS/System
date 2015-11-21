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

end