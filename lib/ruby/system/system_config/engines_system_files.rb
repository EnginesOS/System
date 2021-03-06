class SystemConfig
  @@ReleaseFile = '/opt/engines/release'
  @@FlavorFile = '/opt/engines/flavor'
  @@DomainsFile = '/opt/engines/etc/domains/domains'

  @@NoRemoteExceptionLoggingFlagFile = '/opt/engines/run/system/flags/no_remote_exception_log'

  @@EnginesInternalCA = '/var/lib/engines/services/certs/store/public/ca/certs/system_CA.pem'

  @@SystemPreferencesFile = '/opt/engines/etc/preferences/settings.yaml'
  @@engines_ssh_private_keyfile = '/home/engines/.ssh/system/sshaccess'
  @@ManagedEngineMountsFile = '/opt/engines/etc/create_mounts/engines.yaml'
  @@ManagedServiceMountsFile = '/opt/engines/etc/create_mounts/services.yaml'
  @@SystemAccessDB = '/home/app/db/production.sqlite3'
  @@SystemUserSettingsFile = '/home/engines/deployment/settings.yaml'
  @@BaseOSUpdateRunningLog = '/var/log/engines/updates/base_os_update.running'
  
  def SystemConfig.BaseOSUpdateRunningLog
    @@BaseOSUpdateRunningLog
  end
 
  def SystemConfig.SystemUserSettingsFile
    @@SystemUserSettingsFile
  end

  def SystemConfig.SystemAccessDB
    @@SystemAccessDB
  end

  def SystemConfig.ReleaseFile
    @@ReleaseFile
  end

  def SystemConfig.FlavorFile
    @@FlavorFile
  end

  def SystemConfig.EnginesInternalCA
    @@EnginesInternalCA
  end

  def SystemConfig.ManagedEngineMountsFile
    @@ManagedEngineMountsFile
  end

  def SystemConfig.ManagedServiceMountsFile
    @@ManagedServiceMountsFile
  end

  #  def SystemConfig.generate_ssh_private_keyfile
  #    return  @@generate_ssh_private_keyfile
  #  end
  def SystemConfig.NoRemoteExceptionLoggingFlagFile
    @@NoRemoteExceptionLoggingFlagFile
  end

  def SystemConfig.SystemPreferencesFile
    @@SystemPreferencesFile
  end

  def SystemConfig.engines_ssh_private_keyfile
    @@engines_ssh_private_keyfile
  end

  def SystemConfig.DomainsFile
    @@DomainsFile
  end

end