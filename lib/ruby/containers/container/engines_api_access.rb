module EnginesApiAccess
  def has_api?
    raise EnginesException.new(error_hash('No connection to Engines OS System', nil)) if container_dock.nil?
    true
  end

  def logs_container(count = 100)
    container_dock.logs_container(id, count)
  end

  def ps_container
    raise EnginesException.new(warning_hash("Can\'t ps stopped container", '')) unless is_running?
    container_dock.ps_container(id)
  end

end