module ManagedContainerEnvironment
  def update_environment(key, value, add = false)
    #  SystemDebug.debug(SystemDebug.containers, :update_environment, key, value, @environments)
    raise EnginesException.new(error_hash('No envionment variables')) if @environments.nil?
    s = false
    if add == true
      SystemDebug.debug(SystemDebug.containers, :update_environment, "added")
    env = EnvironmentVariable.new({name: key.to_s, value: value})
      @environments.push(env)
    else
      @environments.each do |environment|
        if environment.name.to_s == key.to_s
          SystemDebug.debug(SystemDebug.containers, :update_environment, "Changed")
          raise EnginesException.new(error_hash('Locked variable ', environment.name )) if environment.immutable == true
          environment.value = value
          s = true
          break
        end
      end
      if s == false
        raise EnginesException.new(error_hash('no matching variable ' + key.to_s))
      end
    end
    true
  end
end