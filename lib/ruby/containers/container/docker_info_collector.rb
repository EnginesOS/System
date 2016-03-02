module DockerInfoCollector
  def docker_info
    
   if @docker_info_cache.is_a?(FalseClass)
     return collect_docker_info if @setState != 'nocontainer'
    return false 
   end
   
   collect_docker_info if @docker_info_cache.nil?  
    
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
    if @container_id.to_s == '-1'  || @container_id.to_s == '' || @container_id.is_a?(FalseClass)
      @container_id =  read_container_id 
      save_state unless @container_id.to_s == '-1' 
    end
  end
    
  def clear_cid
    @container_id =  -1
    ContainerStateFiles.clear_cid_file(self)
    SystemDebug.debug(SystemDebug.containers, 'clear cid')
    save_state   
  end

  # Kludge until using docker socker to create (thne get id back on build completion)
  def read_container_id
    @container_id = ContainerStateFiles.read_container_id(self)
    SystemDebug.debug(SystemDebug.containers, 'read container from file ',  @container_id)
   if @container_id == -1 && setState != 'nocontainer'
#    sleep 1
   
#    ContainerStateFiles.read_container_id(self)
     info  =  @container_api.inspect_container_by_name(self) # docker_info
     return @container_api if info.nil?
   SystemDebug.debug(SystemDebug.containers, 'DockerInfoCollector:Meth read_container_id ' ,info)
    if info.is_a?(Array)
      SystemDebug.debug(SystemDebug.containers,'array')
       info = info[0]
       
   end 
    SystemDebug.debug(SystemDebug.containers, 'DockerInfoCollector:Meth read_container_id ' ,info) 
   # SystemUtils.deal_with_jason(info)
   # SystemDebug.debug(SystemDebug.containers, 'DockerInfoCollector:Meth read_container_id ' ,info)
    if info.is_a?(Hash)
      SystemDebug.debug(SystemDebug.containers,'hash')
    end
   return -1 if info .key?('RepoTags') #No container by that name and it will return images by that name WTF
    @container_id = info['Id'] if info.key?('Id')
     SystemDebug.debug(SystemDebug.containers,@container_id)
     
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
   # SystemDebug.debug(SystemDebug.containers,  :collect_docker_info )
    return false if @docker_info_cache == false && @setState == 'nocontainer'
    @docker_info_cache =  @container_api.inspect_container(self) if @docker_info_cache.nil?
    SystemDebug.debug(SystemDebug.containers,  :collect_docker_info,@docker_info_cache )
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
    if  @docker_info_cache.is_a?(Array)
      @docker_info_cache = @docker_info_cache[0]
  end
    return @docker_info_cache
  end

end