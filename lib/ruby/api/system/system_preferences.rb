class SystemPreferences
  def initialize
    if File.exist?(SystemConfig.SystemPreferencesFile)
      @preferences = YAML.load(File.read(SystemConfig.SystemPreferencesFile))
    else
      @preferences = {}
    end
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def set_default_domain(params)
    @preferences[:default_domain] = params[:default_domain]
    save_preferences
    return EnginesOSapiResult.success(params[:default_domain], :default_domain)
  rescue StandardError => e
    EnginesOSapiResult.failed(params[:default_domain], e.to_s ,:default_domain)
  end

  def get_default_domain
    return 'unset' unless @preferences.key?(:default_domain)
    return @preferences[:default_domain]
  rescue StandardError => e
    SystemUtils.log_exception(e)
    return 'err'
  end

  def save_preferences
    if File.exist?(SystemConfig.SystemPreferencesFile)
      File.rename(SystemConfig.SystemPreferencesFile, SystemConfig.SystemPreferencesFile + '.bak')
    end
    serialized_object = YAML.dump(@preferences)
    f = File.new(SystemConfig.SystemPreferencesFile, File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.puts(serialized_object)
    f.close
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end
end
