module ContainerChangeMonitor
  @change_register = nil
  
  def inform_container_monitor(container_name,ctype,event_name)
     return if event_name.start_with?('exec_')
    add_changed(container_name,ctype,event_name)
  end
  
  def add_changed(container_name,ctype,event_name)
    register  = change_register
    return if ctype.nil?
    return unless register.key?(ctype)    
    register[ctype][container_name] = event_name # unless register[ctype][container_name].nil?    
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