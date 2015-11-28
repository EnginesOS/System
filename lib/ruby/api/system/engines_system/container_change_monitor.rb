module ContainerChangeMonitor
  
  def inform_container_monitor(container_name,ctype,event_name)
    add_changed(container_name,ctype,event_name)
  end
  
  def add_changed(container_name,ctype,event_name)
    change_register[ctype][container_name] = event_name
    
  end
  
  def change_register
    if @change_register == nil
      @change_register = {}
      @change_register['services'] = {}
      @change_register['containers'] = {}
  end
  return @change_register 
  end
  
  def get_changed_containers
    ret = @change_register.dup
    @change_register = nil
    return ret
  end
  
end