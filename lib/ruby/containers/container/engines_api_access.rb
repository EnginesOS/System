module EnginesApiAccess
  def has_api?
    raise EnginesException.new(error_hash('No connection to Engines OS System', nil)) if @container_api.nil?
    true
  end

  def logs_container(count = 100)
    @container_api.logs_container(self, count)
  end

  def ps_container
    raise EnginesException.new(warning_hash("Can\'t ps stopped container", '')) unless is_running?
    @container_api.ps_container(self)
  end

end