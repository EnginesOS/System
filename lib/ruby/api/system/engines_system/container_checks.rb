module ContainerChecks
  def containers_check_and_act
    
    services_status = get_services_status
   results = check_and_act(services_status, 'service')
    engines_status = get_engines_status
    results.merge!(check_and_act(engines_status, 'container'))
      results
  end
  protected
  
  def check_and_act(containers_status, ctype)
    result = {}
    containers_status.keys.each do |container_name|    
      if containers_status[container_name][:error] == true
      result[container_name] = act_on(container_name, ctype)
    else
        result[container_name] = 'ok'
     end       
   end
result
  end
  
  def act_on(container_name, ctype)
    if ctype == 'container'
      container = loadManagedEngine(container_name)
    elsif ctype == 'service'
      container = loadManagedService(container_name)
    else
      container = loadSystemService(container_name)
    end
    
    return container if container.is_a?(EnginesError)
    
    r = container.correct_current_state
    return r if r.is_a?(EnginesError)
    
     'fixed'
    
  
  end
end