module DockerInfoCollector
  def docker_info
    if @docker_info_cache.is_a?(FalseClass)
      return collect_docker_info if @setState != 'nocontainer'
      return false
    else
      collect_docker_info if @docker_info_cache.nil?
      return false if @docker_info_cache.nil?
    end
    @docker_info_cache
  end

  def expire_engine_info
    @docker_info_cache = nil
    true
  end

  # @return a containers ip address as a [String]
  # @return nil if exception
  # @ return false on inspect container error
  def get_ip_str
    if docker_info.is_a?(FalseClass)
      false
    else
      if docker_info[:NetworkSettings][:IPAddress] != ''
      docker_info[:NetworkSettings][:IPAddress]
      else
        false
        end
    end
  rescue
    nil
  end

  def set_cont_id
    if @container_id.to_s == '-1'  || @container_id.to_s == '' || @container_id.is_a?(FalseClass)|| @container_id.is_a?(TrueClass)
      @container_id = read_container_id
      save_state unless @container_id.to_s == '-1'
    end
  end

  def clear_cid
    STDERR.puts caller.join("\n")
   # unless @container_id ==  -1  ## May break if just set to -1 Just here o test
    @container_id =  -1 
    ContainerStateFiles.clear_cid_file(self)
    SystemDebug.debug(SystemDebug.containers, 'clear cid')
    save_state
  #  end
  end

  # Kludge until using docker socker to create (thne get id back on build completion)
  def read_container_id
    cid = @container_id
    @container_id = ContainerStateFiles.read_container_id(self)
    SystemDebug.debug(SystemDebug.containers, 'read container from file ', @container_id)
    if @container_id == -1 && setState != 'nocontainer'
      info = @container_api.inspect_container_by_name(self) # docker_info
      return -1 if info.nil?

      SystemDebug.debug(SystemDebug.containers, 'DockerInfoCollector:Meth read_container_id ', info)
      if info.is_a?(Array)
        SystemDebug.debug(SystemDebug.containers, 'array')
        info = info[0]
        return -1 if info.nil?
      end
      SystemDebug.debug(SystemDebug.containers, 'DockerInfoCollector:Meth read_container_id ', info)
      if info.is_a?(Hash)
        SystemDebug.debug(SystemDebug.containers, 'hash')
      end
      return -1 unless info.is_a?(Hash)
      return -1 if info.key?(:RepoTags) #No container by that name and it will return images by that name WTF
      @container_id = info[:Id] if info.key?(:Id)
      SystemDebug.debug(SystemDebug.containers, @container_id)
    end
    save_state unless cid == @container_id
    @container_id
  rescue EnginesException
    clear_cid
    -1
  end

  def running_user
    info = docker_info
    r = false
    if info.is_a?(Hash)
      if info.key?(:Config)
        if info[:Config].key?(:User)
          r = info[:Config][:User]
        end
      end
    end
    r
  end
  protected

  def collect_docker_info
    # SystemDebug.debug(SystemDebug.containers,  :collect_docker_info )
    if @docker_info_cache == false && @setState == 'nocontainer'
      false
    else
      @docker_info_cache = @container_api.inspect_container(self) if @docker_info_cache.nil?

      if @docker_info_cache.is_a?(Array)
        @docker_info_cache = @docker_info_cache[0]
      end
      @docker_info_cache
    end
  rescue EnginesException
    @docker_info_cache = nil
  end

end