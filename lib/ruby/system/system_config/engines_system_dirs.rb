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
  @@EnginesTemp='/opt/engines/tmp'
  @@CertificatesDir='/var/lib/engines/cert_auth/public/certs/'
  @@KeysDir='/var/lib/engines/cert_auth/public/keys/'
  @@CertificatesDestination='/engines/ssl/public/certs/'
  @@KeyDestination='/engines/ssl/public/keys/' 
  @@DomainsFile = '/opt/engines/etc/domains/domains'
  @@timeZone_fileMapping = ' -v /etc/localtime:/etc/localtime:ro '
  @@NoRemoteExceptionLoggingFlagFile = '/opt/engines/run/system/flags/no_remote_exception_log'
  @@SSHStore = '/opt/engines/etc/ssh/keys'

  def SystemConfig.SSHStore
    return @@SSHStore
  end
  
  def SystemConfig.CertificatesDir
    return @@CertificatesDir
  end
  def SystemConfig.ServiceMapTemplateDir
    return @@ServiceMapTemplateDir
  end
  
  def SystemConfig.EnginesTemp
    return @@EnginesTemp
  end

  def SystemConfig.ServiceTemplateDir
    return @@ServiceTemplateDir
  end

  def SystemConfig.SystemLogRoot
    return @@SystemLogRoot
  end

  def SystemConfig.galleriesDir
    return @@galleriesDir
  end

  def SystemConfig.ContainersDir
    return @@ContainersDir
  end

  def SystemConfig.LocalFSVolHome
    return @@LocalFSVolHome
  end

  def SystemConfig.CONTFSVolHome
    return @@CONTFSVolHome
  end

  def SystemConfig.DeploymentTemplates
    return @@DeploymentTemplates
  end

  def SystemConfig.CidDir
    return @@CidDir
  end

  def SystemConfig.DeploymentDir
    return @@DeploymentDir
  end

  def SystemConfig.RunDir
    return @@RunDir
  end

  def SystemConfig.SystemLogRoot
    return @@SystemLogRoot
  end

end