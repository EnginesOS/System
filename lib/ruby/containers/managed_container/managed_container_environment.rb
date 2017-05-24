module ManagedContainerEnvironment
  def update_environment(key, value, add = false)
    #  SystemDebug.debug(SystemDebug.containers, :update_environment, key, value, @environments)
    raise EnginesException.new(error_hash('No envionment variables')) if @environments.nil?

    @environments.each do |environment|
      if environment.name.to_s == key.to_s
        SystemDebug.debug(SystemDebug.containers, :update_environment, "Changed")
        raise EnginesException.new(error_hash('Locked variable ', environment.name ))  if environment.immutable == true
        environment.value = value
        return
      end
    end

    if add == true
      SystemDebug.debug(SystemDebug.containers, :update_environment, "added")
      env = EnvironmentVariable.new(key.to_s, value)
      @environments.push(env)
    end
    raise EnginesException.new(error_hash('no matching variable ' + key.to_s ))
  end
end