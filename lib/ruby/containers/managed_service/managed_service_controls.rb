module ManagedServiceControls
  def start_container
    super
  end

  def create_service()
    #SystemUtils.run_command('/opt/engines/system/scripts/system/setup_service_dir.sh ' + container_name)
    setup_service_keys if @system_keys.is_a?(Array)
    @container_api.setup_service_dirs(self)
    SystemDebug.debug(SystemDebug.containers, :keys_set, @system_keys )
    envs = @container_api.load_and_attach_pre_services(self)
    shared_envs = @container_api.load_and_attach_shared_services(self)
    if shared_envs.is_a?(Array)
      if envs.is_a?(Array) == false
        envs = shared_envs
      else
        #envs.concat(shared_envs)
        envs = EnvironmentVariable.merge_envs(shared_envs, envs)
      end
    end
    if envs.is_a?(Array)
      if@environments.is_a?(Array)
        @environments =  EnvironmentVariable.merge_envs(envs, @environments)
        # @environments = envs ??
        @environments = EnvironmentVariable.merge_envs(@environments, iso_envs)
      end
    end

    create_container
    save_state()
  rescue EnginesException =>e
    save_state
    raise e
  end

  def recreate
    destroy_container
    wait_for('destroy', 30)
    create_service
    save_state
  rescue EnginesException =>e
    save_state
    raise e
  end

  def iso_envs
    prefs = SystemPreferences.new
    country = prefs.country_code
    country = SystemConfig.DefaultCountry if country.nil?
    lang = prefs.langauge_code
    lang = SystemConfig.DefaultLanguage if lang.nil?
    [EnvironmentVariable.new('LANGUAGE', lang + '_' + country + ':' + lang) ,
      EnvironmentVariable.new('LANG', lang + '_' + country + '.UTF8' ),
      EnvironmentVariable.new('LC_ALL', lang + '_' + country + '.UTF8' )
    ]
  end

  def service_restore(stream, params)
    @container_api.service_restore(self, stream, params)
  end

  private

  def setup_service_keys
    keys = ''
    @system_keys.each do |key|
      keys += ' ' + key.to_s
    end
    SystemDebug.debug(SystemDebug.containers, :keys, keys)
    SystemUtils.run_command('/opt/engines/system/scripts/system/setup_service_keys.sh ' + container_name  + keys)
  end

end