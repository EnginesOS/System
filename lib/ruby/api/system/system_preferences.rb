class SystemPreferences
  def initialize
    if File.exist?(SystemConfig.SystemPreferencesFile)
      @preferences = YAML.load(File.read(SystemConfig.SystemPreferencesFile))
    else
      @preferences = {}
    end
  end

  def set_country_code(country_code)
    @preferences[:country_code] = country_code
    save_preferences
  end

  def set_langauge_code(lang_code)
    @preferences[:lang_code] = lang_code
    save_preferences
  end

  def country_code
    @preferences[:country_code]
  end

  def langauge_code
    @preferences[:lang_code]
  end

  def set_default_domain(params)
    domain_name = params
    domain_name = params[:default_domain] unless domain_name.is_a?(String)
    return false if domain_name.to_s == ''
    @preferences[:default_domain] = domain_name # params[:default_domain]
    save_preferences
  end

  def get_default_domain
    return 'unset' unless @preferences.key?(:default_domain)
    @preferences[:default_domain]
  end

  def save_preferences
    if File.exist?(SystemConfig.SystemPreferencesFile)
      File.rename(SystemConfig.SystemPreferencesFile, SystemConfig.SystemPreferencesFile + '.bak')
    end
    serialized_object = YAML.dump(@preferences)
    f = File.new(SystemConfig.SystemPreferencesFile, File::CREAT | File::TRUNC | File::RDWR, 0644)
    f.puts(serialized_object)
    f.close
  end
end
