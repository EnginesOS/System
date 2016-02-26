module DockerInfoCollector
  def docker_info
    collect_docker_info if @docker_info_cache.nil?
    return false if @docker_info_cache.is_a?(FalseClass)
    return false if @docker_info_cache.nil?

    @docker_info_cache
  rescue StandardError => e
    p @docker_info_cache.to_s
    log_exception(e)
  end

  def expire_engine_info
    @docker_info_cache = nil
    return true
  end

  # @return a containers ip address as a [String]
  # @return nil if exception
  # @ return false on inspect container error
  def get_ip_str
#
    return docker_info['NetworkSettings']['IPAddress'] unless docker_info.is_a?(FalseClass)
    return false
  rescue
    return nil
  rescue StandardError => e
    log_exception(e)
  end
  
  def set_cont_id
    @container_id =  read_container_id if @container_id.to_s == '-1'  || @container_id.to_s == ''
  end
    
  def clear_cid
    @container_id = nil
    save_state
  end

  # Kludge until using docker socker to create (thne get id back on build completion)
  def read_container_id
   r = ContainerStateFiles.read_container_id(self)
   return r #unless r == -1
#    sleep 1
#    ContainerStateFiles.read_container_id(self)
#    info = docker_info
#    return info[0]['Id'] unless info.is_a?(FalseClass) # Array) && docker_info[0].is_a?(Hash)
#    return -1
  rescue StandardError => e
   
    
    log_exception(e)
  end

  def running_user
    info = docker_info
    return -1 if info.is_a?(FalseClass)
    return  info['Config']['User'] unless info.is_a?(FalseClass)
  rescue StandardError => e
    return log_exception(e)
  end
  protected

  def collect_docker_info
    return false unless has_api?
    result = false
    return false if @docker_info_cache == false
    result = @container_api.inspect_container(self) if @docker_info_cache.nil?
    #log_error_mesg('collect false from ', self)
    #@docker_info_cache = @last_result if result
    @docker_info_cache =  result
    #@docker_info_cache = false unless result
   # Thread.new { sleep 4 ; expire_engine_info }
    return result
  end

end