class SystemApi
  @change_register = nil
  def inform_container_monitor(container_name, ctype, event_name)
    #SystemDebug.debug(SystemDebug.container_events, :inform_container_monitor, container_name, ctype, event_name)
    unless event_name.start_with?('exec_')
      add_changed(container_name, ctype, event_name)
    end
  end

  def add_changed(container_name, ctype, event_name)
    register = change_register
    unless ctype.nil?
      if register.key?(ctype)
        register[ctype][container_name] = event_name # unless register[ctype][container_name].nil?
      end
    end
  end

  def change_register
    if @change_register == nil
      @change_register = {
        'service' => {},
        'app' => {}
      }
    end
    @change_register
  end

  def get_changed_containers
    ret = change_register.dup
    @change_register = nil
    ret
  end

end