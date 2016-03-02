module DockerEvents
  require '/opt/engines/lib/ruby/api/system/docker/docker_api/docker_event_watcher.rb'

  def container_event(hash)
    
    status = hash['status']
       s = status.split(':')
       if s.count > 1
         event_name = s[0]
         data = status
       else
         event_name = status
         data = nil
       end
       
   unless hash.key?('from')
    #p :container_event
     SystemDebug.debug(SystemDebug.docker, hash)
    id = hash['Id']
     container_name = container_name_from_id(id)
   else   
        container_name = hash['from'].to_s
     if container_name.start_with?('engines/')    
       c_name = container_name.sub(/engines\//,'')
        c_name.sub!(/:.*/,'')
        ctype = 'service'
      else    
        ctype = 'container'
        c_name = container_name
      end 
  end
  
  return false if c_name.nil?
  return false if ctype.nil?
  return false unless File.exist?(SystemConfig.RunDir + '/' + ctype + 's/' + c_name + '/running.yaml')
  tracked = true
  case event_name
      when 'start'
    inform_container(c_name,ctype,event_name)
      when 'stop'
    inform_container(c_name,ctype,event_name)
      when 'pause'  
    inform_container(c_name,ctype,event_name)
      when 'unpause'
    inform_container(c_name,ctype,event_name)
      when 'create'
    inform_container(c_name,ctype,event_name)
      when 'destroy'
    inform_container(c_name,ctype,event_name)
  else
    SystemDebug.debug(SystemDebug.container_events, 'Untracked event',event_name,c_name,ctype )
    tracked = false
     end
 
  inform_container_monitor(container_name,ctype,event_name) if tracked #unless event_name.start_with?('exec_')
end

 def inform_container(container_name,ctype,event_name)
   SystemDebug.debug(SystemDebug.container_events, 'recevied inform_container',container_name,event_name)
    c = container_from_cache(container_name)   
    if c.nil?
      c = loadManagedEngine(container_name)  if ctype == 'container'
      c = loadManagedService(container_name)  if ctype == 'service'
    end
    return false if c.nil?
   return false if c.is_a?(FalseClass)
   SystemDebug.debug(SystemDebug.container_events, 'informed _container',container_name,event_name)
    c.task_complete(event_name)
  return true
  rescue StandardError =>e
    log_exception(e)
  end

  def start_docker_event_listener
    docker_event_listener = DockerEventWatcher.new(self)
    Thread.new {  docker_event_listener.start}

  rescue StandardError =>e
    log_exception(e)

  end
end