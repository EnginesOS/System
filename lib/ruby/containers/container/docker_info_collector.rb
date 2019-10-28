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
    if @id.to_s == '-1'  || @id.to_s == '' || @id.is_a?(FalseClass)|| @id.is_a?(TrueClass)
      @id = read_container_id
      save_state unless @id.to_s == '-1'
    end
  end

  def clear_cid
    # STDERR.puts caller.join("\n")
    # unless @id ==  -1  ## May break if just set to -1 Just here o test
    @id =  -1
    ContainerStateFiles.clear_cid_file(store_address)
    # SystemDebug.debug(SystemDebug.containers, 'clear cid')
    save_state
    #  end
  end

  # Kludge until using docker socker to create (thne get id back on build completion)
  def read_container_id    
    @id = ContainerStateFiles.read_container_id(store_address)
    cid = @id
    #  SystemDebug.debug(SystemDebug.containers, 'read container from file ', @container_id)
    if @id == -1 || @id.nil? # && setState != 'nocontainer'
      info = container_api.inspect_container_by_name(@container_name) # docker_info
      info = info[0] if info.is_a?(Array)
      if info.key?(:RepoTags)
        #No container by that name and it will return images by that name WTF
        @id = -1
      else
        @id = info[:Id] if info.key?(:Id)
      end
    end
    save_state unless cid == @id
    @id
  rescue EnginesException
    clear_cid unless  cid == -1
    @id = -1
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
      @docker_info_cache = container_api.inspect_container(container_id) if @docker_info_cache.nil?
      @docker_info_cache = @docker_info_cache[0] if @docker_info_cache.is_a?(Array)
      @docker_info_cache
    end
  rescue EnginesException
    @docker_info_cache = nil
  end

end