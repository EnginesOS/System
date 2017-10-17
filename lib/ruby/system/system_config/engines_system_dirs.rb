module EnginesSystemDirs

  @@RunDir = '/opt/engines/run/'
  @@CidDir = '/opt/engines/run/cid/'
  @@ContainersDir = '/opt/engines/run/containers/'
  @@DeploymentDir = '/home/engines/deployment/deployed'
  @@DeploymentTemplates = '/opt/engines/system/templates/deployment'
  @@CONTFSVolHome = '/home/app/fs'
  @@LocalFSVolHome = '/var/lib/engines/fs'
  @@galleriesDir = '/opt/engines/etc/galleries'
  @@SystemLogRoot = '/var/log/engines/'
  @@ServiceMapTemplateDir = '/opt/engines/etc/services/mapping/'
  @@ServiceTemplateDir = '/opt/engines/etc/services/providers/'
  @@EnginesTemp = '/opt/engines/tmp'
  @@CertificatesDir = '/var/lib/engines/services/cert_auth/public/certs/'
  @@KeysDir ='/var/lib/engines/services/cert_auth/public/keys/'
  @@CertificatesDestination = '/engines/ssl/certs/'
  @@KeysDestination = '/engines/ssl/keys/'
  @@DomainsFile = '/opt/engines/etc/domains/domains'
  @@timeZone_fileMapping = ' -v /etc/localtime:/etc/localtime:ro '
  @@NoRemoteExceptionLoggingFlagFile = '/opt/engines/run/system/flags/no_remote_exception_log'
  @@SSHStore = '/opt/engines/etc/ssh/keys'
  @@CertAuthTop = '/var/lib/engines/services/cert_auth/'
  
  def SystemConfig.CertAuthTop
    @@CertAuthTop
  end
  
  def SystemConfig.SSHStore
    @@SSHStore
  end

  def SystemConfig.CertificatesDestination
    @@CertificatesDestination
  end

  def SystemConfig.KeysDir
    @@KeysDir
  end

  def SystemConfig.KeysDestination
    @@KeysDestination
  end

  def SystemConfig.CertificatesDir
    @@CertificatesDir
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