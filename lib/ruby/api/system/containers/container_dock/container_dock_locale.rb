module ContainerDockLocale
  def set_locale_env(container)
    container.environments.each do |env|
       if env.name == 'LANG'
         return         
       elsif env.name == 'LC_ALL'
         return
       elsif env.name == 'LANGUAGE'
         return
       end
    end
    add_locale_envs(container)
  end

  def add_locale_envs(container)
    prefs = SystemPreferences.new
    lang = prefs.langauge_code
    country = prefs.country_code
    container.environments.push(EnvironmentVariable.new(
      { name: 'LANGUAGE',
        value: "#{lang}_#{country}:#{lang}",
        owner_type: 'system'
      }))
    container.environments.push(EnvironmentVariable.new(
    { name: 'LANG', 
      value: "#{lang}_#{country}.UTF8",
      owner_type: 'system'
    }))
    container.environments.push(EnvironmentVariable.new({
     name: 'LC_ALL', 
     value: "#{lang}_#{country}.UTF8",
      owner_type: 'system'
    }))    
  end
end