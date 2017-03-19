module PublicApiSystemVersions
  # @return [String]
  # return system release string current|master|beta-rc|...
  def  get_engines_system_release
    SystemStatus.get_engines_system_release
  end

  # @return [Integer]
  # returnes the api version number
  def api_version
    return SystemConfig.api_version
  end

  def version_string
    SystemUtils.version
  end

  def system_version
    SystemConfig.engines_system_version
  end

  # @return [Hash]
  # return Operating Systems version data
  def get_os_release_data
    SystemUtils.get_os_release_data
  end
end