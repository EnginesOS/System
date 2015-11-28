module ContainerChangeMonitor
  @change_register = nil
  
  def inform_container_monitor(container_name,ctype,event_name)
    add_changed(container_name,ctype,event_name)
  end
  
  def add_changed(container_name,ctype,event_name)
    register  = change_register
   register[ctype][container_name] = event_name
    
  end
  
  def change_register
    if @change_register == nil
      @change_register = {}
      @change_register['service'] = {}
      @change_register['container'] = {}
  end
  return @change_register 
  end
  
  def get_changed_containers
    ret = @change_register.dup
    @change_register = nil
    return ret
  end
  
end