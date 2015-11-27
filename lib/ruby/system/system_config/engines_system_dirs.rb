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

  @@ReleaseFile= '/opt/engines/release'
  @@DomainsFile = '/opt/engines/etc/domains/domains'
  @@timeZone_fileMapping = ' -v /etc/localtime:/etc/localtime:ro '
  @@NoRemoteExceptionLoggingFlagFile = '/opt/engines/run/system/flags/no_remote_exception_log'
  def SystemConfig.ServiceMapTemplateDir
    return @@ServiceMapTemplateDir
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