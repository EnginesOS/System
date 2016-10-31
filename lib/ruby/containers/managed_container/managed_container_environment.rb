module ManagedContainerEnvironment
  def update_environment(key,value, add=false)
    SystemDebug.debug(SystemDebug.containers, :update_environment, key, value, @environments)
    return log_error_mesg('No envionment varaibles') if @environments.nil?
    
    @environments.each do |environment|    
    if environment.name == key.to_s
      STDERR.puts(' Evn ' + environment.name.to_s  + ':' + environment.value.to_s) 
      SystemDebug.debug(SystemDebug.containers, :update_environment, "Changed")
      return log_error_mesg(' variable ' + environment.name + ' immutable' )  if environment.immutable == true
      environment.value = value 
      return true
    end
    return log_error_mesg('no matching variable ' + environment.name )  
    end
    
    if add == true
      SystemDebug.debug(SystemDebug.containers, :update_environment, "added")
      env = EnvironmentVariable.new(key.to_s,value)
      @environments.push(env)
      return true
    end
    
  rescue StandardError => e
    log_exception(e,:update_environment,key,value, add)
  end
end