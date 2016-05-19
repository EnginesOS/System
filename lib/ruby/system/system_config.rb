class SystemConfig

  require_relative 'system_config/engines_system_flags.rb'
  extend EnginesSystemFlags

  require_relative 'system_config/builder_settings.rb'
  extend BuilderSettings
  require_relative 'system_config/engines_system_dirs.rb'
  extend EnginesSystemDirs

  require_relative 'system_config/engines_system_files.rb'
  extend EnginesSystemFiles

  @@api_version = '0.1'
  @@engines_system_version = '0.1'
  @@RegistryPort = 21027
  @@default_webport = 8000

  #  @@RunDir = '/opt/engines/run/'
  #  @@CidDir = '/opt/engines/run/cid/'
  #  @@ContainersDir = '/opt/engines/run/containers/'
  #  @@DeploymentDir = '/home/engines/deployment/deployed'
  #  @@DeploymentTemplates = '/opt/engines/system/templates/deployment'
  #  @@CONTFSVolHome = '/home/app/fs'
  #  @@LocalFSVolHome = '/var/lib/engines/fs'
  #  @@galleriesDir = '/opt/engines/etc/galleries'
  #  @@SystemLogRoot = '/var/log/engines/'
  #  @@ServiceMapTemplateDir = '/opt/engines/etc/services/mapping/'
  #  @@ServiceTemplateDir = '/opt/engines/etc/services/providers/'



  @@SMTPHost = 'smtp.engines.internal'
  @@DBHost = 'mysql.engines.internal'
  @@internal_domain = 'engines.internal'

  @@MinimumFreeRam = 64
  @@MinimumBuildRam  = @@MinimumFreeRam + 128
  def self.MinimumBuildRam
     @@MinimumBuildRam
   end
  
  
  @@MinimumFreeImageSpace = 2000
  def self.MinimumFreeImageSpace
    @@MinimumFreeImageSpace
  end

  def self.MinimumFreeRam
    @@MinimumFreeRam
  end

  def self.registry_connect_timeout
    return 60
  end

  def SystemConfig.RegistryPort
    return @@RegistryPort
  end

  def SystemConfig.api_version
    return @@api_version
  end
  @@api_version = '0.0'

  @@engines_system_version = '0.0'

  def SystemConfig.engines_system_version
    return @@engines_system_version
  end

  def SystemConfig.default_webport
    return @@default_webport
  end

  def SystemConfig.SMTPHost
    return @@SMTPHost
  end

  def SystemConfig.internal_domain
    return @@internal_domain
  end


  def SystemConfig.DBHost
    return @@DBHost
  end

end