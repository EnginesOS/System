module DockerInfoCollector
  def docker_info
    if @docker_info_cache.is_a?(FalseClass)
      return collect_docker_info if set_state != 'nocontainer'
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

  def clear_cid
    # STDERR.puts caller.join("\n")
    id = nil
    store.clear_cid_file(container_name)
    # SystemDebug.debug(SystemDebug.containers, 'clear cid')
    save_state
  end

  # Kludge until using docker socker to create (thne get id back on build completion)
  def read_container_id
    #kludge to update any old
    cid = id
    id = nil if id.to_s == '-1'
    #  SystemDebug.debug(SystemDebug.containers, 'read container from file ', @id)
    if id.nil?
      info = container_dock.inspect_container_by_name(container_name) # docker_info
      SystemDebug.debug(SystemDebug.containers, 'read container id by name', container_name)
      #      begin SHOULD NOT NEED PAST DOCKER BUG LEAVE COMMENTED UNTIL 1/1/2020
      #        info = info[0] if info.is_a?(Array)
      #      rescue StandardError #was is a Array
      #        nil
      #      end
      begin
        if info.key?(:RepoTags)
          #No container by that name and it will return images by that name WTF
          SystemDebug.debug(SystemDebug.containers, 'read container id by name got image')
          id = nil
        else
          id = info[:Id] if info.key?(:Id)
        end
      rescue NoMethodError => e # docker did not return valid json so no such container
        id = nil
      end
      #save_state
    end
    SystemDebug.debug(SystemDebug.containers, 'read container id', id)
    id
  rescue EnginesException
    clear_cid unless cid == nil
    id = nil
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
    if @docker_info_cache == false && set_state == 'nocontainer'
      SystemDebug.debug(SystemDebug.containers,  :dont_collect_docker_info )
      false
    else
      SystemDebug.debug(SystemDebug.containers,  :collect_docker_info )
      read_container_id if id.nil?
      unless id.nil?
        @docker_info_cache = container_dock.inspect_container(id) if @docker_info_cache.nil?
        @docker_info_cache = @docker_info_cache[0] if @docker_info_cache.is_a?(Array)
        @docker_info_cache
      else
        @docker_info_cache = nil
      end
    end
  rescue EnginesException
    @docker_info_cache = nil
  end

end