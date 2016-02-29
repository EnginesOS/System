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
    @container_id = ContainerStateFiles.read_container_id(self)
    SystemDebug.debug(SystemDebug.containers, 'read container from file ',  @container_id)
   if @container_id == -1 && setState != 'nocontainer'
#    sleep 1
     @container_api.inspect_container_by_name
#    ContainerStateFiles.read_container_id(self)
     info  =  @container_api.inspect_container_by_name(self) # docker_info
   SystemDebug.debug(SystemDebug.containers, 'DockerInfoCollector:Meth read_container_id ' ,info)
    if info.is_a?(Hash)
       @container_id = info['Id']
    end
#     save_container
#     else
#     SystemDebug.debug(SystemDebug.containers, ' DockerInfoCollector:Meth ' ,info)
#     @container_id  = -1   
#   end       
  end
  
  return  @container_id
  rescue StandardError => e      
    log_exception(e)
  end

  def running_user
    info = docker_info
    return -1 unless info.is_a?(Hash)
    return -1 unless info.key?('Config')
    return -1 unless info['Config'].key?('User')
    return  info['Config']['User'] 
  rescue StandardError => e
    return log_exception(e,info)
  end
  protected

  def collect_docker_info
    return false unless has_api?
    return false if @docker_info_cache == false 
    @docker_info_cache =  @container_api.inspect_container(self) if @docker_info_cache.nil?
#    if @docker_info_cache == false
#      @container_id = -1
##    elsif @docker_info_cache.is_a?(Array)
##      @docker_info_cache =  @docker_info_cache[0]
##      if @container_id.to_s == '' || @container_id == -1      
##        @container_id = @docker_info_cache['Id']
##      end
#    end
    #log_error_mesg('collect false from ', self)
    #@docker_info_cache = @last_result if result
    # result    
    #@docker_info_cache = false unless result
   # Thread.new { sleep 4 ; expire_engine_info }
    return @docker_info_cache
  end

end