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
    unless @preferences.key?(:country_code)
      @preferences[:country_code] = SystemConfig.DefaultCountry
      save_preferences
    end
    @preferences[:country_code]
  end

  def langauge_code
    unless @preferences.key?(:lang_code)
      @preferences[:lang_code] = SystemConfig.DefaultLanguage
      save_preferences
    end
    @preferences[:lang_code]
  end

  def set_default_domain(params)
    domain_name = params
    domain_name = params[:default_domain] unless domain_name.is_a?(String)
    unless domain_name.to_s == ''
      @preferences[:default_domain] = domain_name # params[:default_domain]
      save_preferences
    else
      false
    end
  end

  def default_domain
    if @preferences.key?(:default_domain)
      @preferences[:default_domain]
    else
      'unset'
    end
  end

  def save_preferences
    if File.exist?(SystemConfig.SystemPreferencesFile)
      File.rename(SystemConfig.SystemPreferencesFile, SystemConfig.SystemPreferencesFile + '.bak')
    end
    serialized_object = YAML.dump(@preferences)
    f = File.new(SystemConfig.SystemPreferencesFile, File::CREAT | File::TRUNC | File::RDWR, 0644)
    begin
      f.puts(serialized_object)
    ensure
      f.close
    end
  end

  def SystemPreferences.set_container_icon_url(container, url)
    url_f = File.new(ContainerStateFiles.container_state_dir(container) + '/icon.url', 'w+')
    begin
      url_f.puts(url)
    ensure
      url_f.close
    end
  rescue StandardError => e
    url_f.close unless url_f.nil?
    raise e
  end

  def SystemPreferences.container_icon_url(container)
    if File.exists?(ContainerStateFiles.container_state_dir(container) + '/icon.url')
      url_f = File.new(ContainerStateFiles.container_state_dir(container) + '/icon.url', 'r')
      begin
        url = url_f.gets(url)
      ensure
        url_f.close
      end
      url.strip
    else
      nil
    end
  rescue StandardError => e
    url_f.close unless url_f.nil?
    raise e
  end
end
