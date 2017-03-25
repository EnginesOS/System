module SystemVersion
  @@api_version = '0.2'
  @@engines_system_version = '0.3'
  def SystemConfig.api_version
    @@api_version
  end

  def SystemConfig.engines_system_version
    @@engines_system_version
  end

end