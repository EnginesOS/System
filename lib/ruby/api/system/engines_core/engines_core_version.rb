module EnginesCoreVersion
  def api_version
    SystemConfig.api_version
  end

  def version_string
    SystemUtils.version
  end

  def system_version
    SystemConfig.engines_system_version
  end

end