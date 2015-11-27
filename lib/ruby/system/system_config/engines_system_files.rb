module EnginesSystemFiles
  @ReleaseFile= '/opt/engines/release'
  @@DomainsFile = '/opt/engines/etc/domains/domains'
  @@timeZone_fileMapping = ' -v /etc/localtime:/etc/localtime:ro '
  @@NoRemoteExceptionLoggingFlagFile = '/opt/engines/run/system/flags/no_remote_exception_log'
  @@EnginesInternalCA = '/opt/engines/etc/ssl/ca/certs/system_CA.pem'

  @@SystemPreferencesFile = '/opt/engines/etc/preferences/settings.yaml'
  @@engines_ssh_private_keyfile = '/home/engines/.ssh/sshaccess'
  def SystemConfig.EnginesInternalCA
    return @@EnginesInternalCA
  end

  #  def SystemConfig.generate_ssh_private_keyfile
  #    return  @@generate_ssh_private_keyfile
  #  end
  def SystemConfig.NoRemoteExceptionLoggingFlagFile
    return @@NoRemoteExceptionLoggingFlagFile
  end

  def SystemConfig.SystemPreferencesFile
    return @@SystemPreferencesFile
  end

  def SystemConfig.engines_ssh_private_keyfile
    return @@engines_ssh_private_keyfile
  end

  def SystemConfig.DefaultBuildReportTemplateFile
    return @@DefaultBuildReportTemplateFile
  end

  def SystemConfig.DomainsFile
    return @@DomainsFile
  end

  def SystemConfig.timeZone_fileMapping
    return @@timeZone_fileMapping
  end
end