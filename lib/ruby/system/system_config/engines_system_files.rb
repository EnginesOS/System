module EnginesSystemFiles
  @@ReleaseFile= '/opt/engines/release'
  @@DomainsFile = '/opt/engines/etc/domains/domains'
  @@timeZone_fileMapping = ' -v /etc/localtime:/etc/localtime:ro '
  @@NoRemoteExceptionLoggingFlagFile = '/opt/engines/run/system/flags/no_remote_exception_log'
  @@EnginesInternalCA = '/var/lib/engines/cert_auth/public/ca/certs/system_CA.pem'

  @@SystemPreferencesFile = '/opt/engines/etc/preferences/settings.yaml'
  @@engines_ssh_private_keyfile = '/home/engines/.ssh/sshaccess'
  @@ManagedEngineMountsFile = '/opt/engines/etc/create_mounts/engines.yaml'
  @@ManagedServiceMountsFile = '/opt/engines/etc/create_mounts/services.yaml'

  @@SystemAccessDB = "/home/app/db/production.sqlite3"
  def self.SystemAccessDB
    @@SystemAccessDB
  end

  def self.ReleaseFile
    @@ReleaseFile
  end

  def self.EnginesInternalCA
    @@EnginesInternalCA
  end

  def self.ManagedEngineMountsFile
    @@ManagedEngineMountsFile
  end

  def self.ManagedServiceMountsFile
    @@ManagedServiceMountsFile
  end

  #  def SystemConfig.generate_ssh_private_keyfile
  #    return  @@generate_ssh_private_keyfile
  #  end
  def self.NoRemoteExceptionLoggingFlagFile
    @@NoRemoteExceptionLoggingFlagFile
  end

  def self.SystemPreferencesFile
    @@SystemPreferencesFile
  end

  def self.engines_ssh_private_keyfile
    @@engines_ssh_private_keyfile
  end

  def self.DomainsFile
    @@DomainsFile
  end

  def self.timeZone_fileMapping
    @@timeZone_fileMapping
  end
end