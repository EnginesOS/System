module EnginesApiAccess
  def has_api?
    return log_error_mesg('No connection to Engines OS System',nil) if @container_api.nil?
     true
  end

  def logs_container(count=100)
    return false unless has_api?
     @container_api.logs_container(self,count)
  end

  def ps_container
    #expire_engine_info
    return false unless has_api?
    return log_error_mesg('Can\'t ps stopped container','') unless is_running?
    @container_api.ps_container(self)
  end

end