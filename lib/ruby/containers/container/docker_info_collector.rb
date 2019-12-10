module DockerInfoCollector
  def docker_info
    #    if @docker_info_cache.is_a?(FalseClass)
    #      return collect_docker_info if set_state != :nocontainer
    #      return false
    #    else
    collect_docker_info if @docker_info_cache.nil?
    return nil if @docker_info_cache.nil?
    #    end
    @docker_info_cache
  end

  def expire_engine_info
    STDERR.puts('Expiring Engines Info')
    @docker_info_cache = nil
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
    self.id = nil
    SystemDebug.debug(SystemDebug.containers, 'clear cid', id)
    save_state    
  end

  # Kludge until using docker socker to create (thne get id back on build completion)
  def read_container_id
    cid = id
    self.id = nil if id.to_s == '-1'     #kludge to update any old
    self.id = container_dock.container_id_from_name(container_name)
    self.state = :nocontainer if id.nil?
    self.id
  rescue EnginesException =>e
    SystemUtils.log_exception(e, container_name, id)    
    clear_cid unless cid == nil
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
    #this is here to avoid hitting the docker everytime to engines in nocontainer state logic needs work
    if @docker_info_cache == nil && set_state == :nocontainer  && state == :nocontainer && id.nil?
      SystemDebug.debug(SystemDebug.containers,  :dont_collect_docker_info )
      false
    else
      SystemDebug.debug(SystemDebug.containers,  :collect_docker_info ,"id:_#{id}_")
      read_container_id if id.nil?
      SystemDebug.debug(SystemDebug.containers,  :collect_docker_info ,"id:_#{id}_")
      unless id.nil?
        @docker_info_cache = container_dock.inspect_container(id) if @docker_info_cache.nil?
        # old Docker bug ?   @docker_info_cache = @docker_info_cache[0] if @docker_info_cache.is_a?(Array)
        @docker_info_cache
      else
        @docker_info_cache = nil
      end
    end
    @docker_info_cache
  rescue EnginesException => e
    STDERR.puts("docker info collect exception \n #{e} ")
    unless e.error_mesg.nil?
      STDERR.puts( "No such container: #{id} == [_#{e.error_mesg}_]" )
      clear_cid if e.error_mesg.eql?("No such container: #{id}")
    end
    @docker_info_cache = nil
  end

end