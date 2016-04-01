module ManagedContainerEnvironment
  def update_environment(key,value, add=false)
    SystemDebug.debug(SystemDebug.containers, :update_environment, key, value, @environments)
    return false if @environments.nil?
    
    @environments.each do |environment|
    if environment.name == key        
      SystemDebug.debug(SystemDebug.containers, :update_environment, "Cahnged")
      environment.value = value
      return true
    end
    end
    
    if add == true
      SystemDebug.debug(SystemDebug.containers, :update_environment, "added")
      env = EnvironmentVariable.new(key,value)
      @environments.push(env)
      return true
    end
    
  rescue StandardError => e
    log_exception(e,:update_environment,key,value, add)
    return false
  end
end