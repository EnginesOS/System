module  ContainerApiLocale
  def set_locale_env(container)
    container.environments.each do |env|
      return if env.name == 'LANG' || env.name == 'LC_ALL'
    end
    add_locale_envs(container)
  end

  def add_locale_envs(container)
    prefs = SystemPreferences.new
    lang = prefs.langauge_code
    country = prefs.country_code
    container.environments.push(EnvironmentVariable.new('LANGUAGE', lang + '_' + country + ':' + lang))
    container.environments.push(EnvironmentVariable.new('LANG', lang + '_' + country + '.UTF8'))
    container.environments.push(EnvironmentVariable.new('LC_ALL', lang + '_' + country + '.UTF8'))
  end
end