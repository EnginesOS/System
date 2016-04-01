module ManagedContainerEnvironment
  def update_environment(key,value, add=false)
    return false if @environments.nil?
    
    @environments.each do |environment|
    if environment.name == key        
      environment.value = value
      return true
    end
    end
    
    if add == true
      env = EnvironmentVariable.new(key,value)
      @environments.push(env)
      return true
    end
    
  rescue StandardError => e
    log_exception(e,:update_environment,key,value, add)
    return false
  end
end