module ContainerControls
  def start_container
    expire_engine_info
    unless is_running?
      raise EnginesException.new(warning_hash("Can\'t Start " + container_name + ' as is ' + read_state.to_s, container_name)) unless read_state == 'stopped'
      container_dock.start_container(self)
    else
      true
    end
  ensure
    expire_engine_info
    false
  end

  def halt_container
    expire_engine_info
    unless is_stopped?
      raise EnginesException.new(warning_hash("Can\'t Stop " + container_name + ' as is ' + read_state.to_s, container_name)) unless read_state == 'running'
      container_dock.stop_container(container_id)
    else
      true
    end
  ensure
    expire_engine_info
    false
  end

  def stop_container
    expire_engine_info
    r = true
    unless is_stopped?
      raise EnginesException.new(warning_hash("Can\'t Stop " + container_name + ' as is ' + read_state.to_s, container_name)) unless read_state == 'running'
      r = container_dock.stop_container(container_id, stop_timeout)
      expire_engine_info
    end
    r
  end

  def wait_for(what, timeout = 10)
    container_dock.wait_for(self, what, timeout)
  end

  def pause_container
    expire_engine_info
    r = true
    unless is_paused?
      raise EnginesException.new(warning_hash("Can\'t Pause " + container_name + ' as is ' + read_state.to_s, container_name)) unless is_running?
      r = container_dock.pause_container(container_id)
      expire_engine_info
    end
    r
  end

  def unpause_container
    expire_engine_info
    r = true
    unless is_running?
      raise EnginesException.new(warning_hash("Can\'t unpause " + container_name + ' as is ' + read_state.to_s, container_name)) unless is_paused?
      r = container_dock.unpause_container(container_id)
      expire_engine_info
    end
    r
  end

  def destroy_container()
    expire_engine_info
    unless has_container?
      @id = nil
      r = true
    else
      raise EnginesException.new(warning_hash('Cannot Destroy ' +  container_name + ' as is not stopped Please stop first', container_name)) if is_active?
      r = container_dock.destroy_container(self)
      @id = nil
      expire_engine_info
    end
    r
  end

  def create_container
    expire_engine_info
    #  SystemDebug.debug(SystemDebug.containers, :create_container, :containerid)
    raise EnginesException.new(warning_hash('Cannot create container as container exists ' + container_name.to_s, container_name)) if has_container?
    @id = nil
    container_dock.create_container(self)
  end

end
