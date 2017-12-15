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

  def get_default_domain
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
    f.puts(serialized_object)
    f.close
  end
  
  def SystemPreferences.set_container_icon_url(container, url)
     url_f = File.new(ContainerStateFiles.container_state_dir(container) + '/icon.url', 'w+')
     url_f.puts(url)
     url_f.close
   rescue StandardError => e
     url_f.close unless url_f.nil?
     raise e
   end
 
   def SystemPreferences.container_icon_url(container)
    if File.exists?(ContainerStateFiles.container_state_dir(container) + '/icon.url')
     url_f = File.new(ContainerStateFiles.container_state_dir(container) + '/icon.url', 'r')
     url = url_f.gets(url)
     url_f.close
     url.strip
    else
      nil
    end
   rescue StandardError => e
     url_f.close unless url_f.nil?
     raise e
   end
end
