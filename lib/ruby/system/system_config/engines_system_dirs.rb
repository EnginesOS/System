class SystemConfig

  @@RunDir = '/opt/engines/run/'
  @@CidDir = '/opt/engines/run/cid/'
  @@ContainersDir = '/opt/engines/run/apps/'
  @@DeploymentDir = '/home/engines/deployment/deployed'
  @@DeploymentTemplates = '/opt/engines/system/templates/deployment'
  @@CONTFSVolHome = '/home/app/fs'
  @@LocalFSVolHome = '/var/lib/engines/apps'
  @@galleriesDir = '/opt/engines/etc/galleries'
  @@SystemLogRoot = '/var/log/engines/'
  @@ServiceMapTemplateDir = '/opt/engines/etc/services/mapping/'
  @@ServiceTemplateDir = '/opt/engines/etc/services/providers/'
  @@EnginesTemp = '/opt/engines/tmp'
  @@InfoTreeDir = '/opt/engines/run/public/services'

  @@DomainsFile = '/opt/engines/etc/domains/domains'

  @@NoRemoteExceptionLoggingFlagFile = '/opt/engines/run/system/flags/no_remote_exception_log'
  @@SSHStore = '/opt/engines/etc/ssh/keys'

  @@KeysDestination = '/home/engines/etc/ssl/keys/'
  @@CertAuthTop = '/var/lib/engines/services/certs/store/live/'
  @@CertificatesDestination = '/home/engines/etc/ssl/certs/'
  @@ServiceBackupScriptsRoot = '/home/engines/scripts/backup/'
  @@EngineServiceBackupScriptsRoot = '/home/engines/scripts/backup/engine/'
  
  #Container UID historical store
  @@ContainerUIDdir = '/opt/engines/etc/containers/uids'
  @@ContainerNextUIDFile = '/opt/engines/etc/containers/uids/next'
  
  @@BackupTmpDir = '/tmp/backup_bundles/'
   
   def SystemConfig.BackupTmpDir
     @@BackupTmpDir
   end
   
  def SystemConfig.ContainerUIDdir
    @@ContainerUIDdir
  end
  def SystemConfig.ContainerNextUIDFile
    @@ContainerNextUIDFile
  end
  
  def SystemConfig.EngineServiceBackupScriptsRoot
    @@EngineServiceBackupScriptsRoot
  end
  def SystemConfig.ServiceBackupScriptsRoot
    @@ServiceBackupScriptsRoot
  end

  def SystemConfig.InfoTreeDir
    @@InfoTreeDir
  end

  def SystemConfig.CertAuthTop
    @@CertAuthTop
  end

  def SystemConfig.SSHStore
    @@SSHStore
  end

  def SystemConfig.CertificatesDestination
    @@CertificatesDestination
  end


  def SystemConfig.KeysDestination
    @@KeysDestination
  end

  def SystemConfig.ServiceMapTemplateDir
    @@ServiceMapTemplateDir
  end

  def SystemConfig.EnginesTemp
    @@EnginesTemp
  end

  def SystemConfig.ServiceTemplateDir
    @@ServiceTemplateDir
  end

  def SystemConfig.SystemLogRoot
    @@SystemLogRoot
  end

  def SystemConfig.galleriesDir
    @@galleriesDir
  end

  def SystemConfig.ContainersDir
    @@ContainersDir
  end

  def SystemConfig.LocalFSVolHome
    @@LocalFSVolHome
  end

  def SystemConfig.CONTFSVolHome
    @@CONTFSVolHome
  end

  def SystemConfig.DeploymentTemplates
    @@DeploymentTemplates
  end

  def SystemConfig.CidDir
    @@CidDir
  end

  def SystemConfig.DeploymentDir
    @@DeploymentDir
  end

  def SystemConfig.RunDir
    @@RunDir
  end

  def SystemConfig.SystemLogRoot
    @@SystemLogRoot
  end

end