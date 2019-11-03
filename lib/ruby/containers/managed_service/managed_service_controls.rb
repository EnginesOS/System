module ManagedServiceControls
  def start_container
    super
  end

  def create_service()
    setup_service_keys if @system_keys.is_a?(Array)
    container_api.setup_service_dirs(self)
    #SystemDebug.debug(SystemDebug.containers, :keys_set, @system_keys )
    envs = container_api.load_and_attach_pre_services(self)
    shared_envs = container_api.load_and_attach_shared_services(self)
    if shared_envs.is_a?(Array)
      if envs.is_a?(Array) == false
        envs = shared_envs
      else
        envs = EnvironmentVariable.merge_envs(shared_envs, envs)
      end
    end
    if envs.is_a?(Array)
      if@environments.is_a?(Array)
        @environments =  EnvironmentVariable.merge_envs(envs, @environments)
      end
    end
    create_container
    save_state
  rescue EnginesException =>e
    save_state
    raise e
  end

  def recreate
    begin
      destroy_container
    rescue EnginesException => e
    end
    wait_for('destroy', 30)
    create_service
    save_state
  rescue EnginesException => e
    save_state
    raise e
  end


  def service_restore(stream, params)
    container_api.service_restore(self, stream, params)
  end

  private

  def setup_service_keys
    keys = ''
    @system_keys.each do |key|
      keys += " #{key}"
    end
   # SystemDebug.debug(SystemDebug.containers, :keys, keys)
    SystemUtils.run_command('/opt/engines/system/scripts/system/setup_service_keys.sh ' + container_name  + keys)
  end

end