class SystemConfig

  require_relative 'system_config/engines_system_flags.rb'
  #extend EnginesSystemFlags

  require_relative 'system_config/builder_settings.rb'
#  extend BuilderSettings
  require_relative 'system_config/engines_system_dirs.rb'
 # extend EnginesSystemDirs

  require_relative 'system_config/engines_system_files.rb'
 # extend EnginesSystemFiles

  require_relative 'system_config/system_version.rb'
 # extend SystemVersion

  @@RegistryPort = 21027
  @@default_webport = 8000


  @@SMTPHost = 'smtp.engines.internal'
  @@DBHost = 'mysql.engines.internal'
  @@internal_domain = 'engines.internal'

  @@MinimumFreeRam = 32
  @@MinimumBuildRam  = @@MinimumFreeRam + 150
  def SystemConfig.MinimumBuildRam
    @@MinimumBuildRam
  end

  @@MinimumFreeImageSpace = 2000

  def SystemConfig.MinimumFreeImageSpace
    @@MinimumFreeImageSpace
  end

  def SystemConfig.MinimumFreeRam
    @@MinimumFreeRam
  end

  def SystemConfig.registry_connect_timeout
    60
  end

  def SystemConfig.RegistryPort
    @@RegistryPort
  end

  def SystemConfig.default_webport
    @@default_webport
  end

  def SystemConfig.SMTPHost
    @@SMTPHost
  end

  def SystemConfig.internal_domain
    @@internal_domain
  end

  def SystemConfig.DBHost
    @@DBHost
  end

end