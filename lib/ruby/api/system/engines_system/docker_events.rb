module DockerEvents
  require '/opt/engines/lib/ruby/api/system/docker/docker_api/docker_event_watcher.rb'

  def container_event(event_hash)
    
    status = event_hash['status']
       s = status.split(':')
       if s.count > 1
         event_name = s[0]
         data = status
       else
         event_name = status
         data = nil
       end
       
   unless event_hash.key?('from')
    #p :container_event
     SystemDebug.debug(SystemDebug.docker, event_hash)
    id = hash['Id']
     container_name = container_name_from_id(id)
   else   
        container_name = event_hash['from'].to_s
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
  inform_container(c_name,ctype,event_name)
  
  case event_name
      when 'start'
    inform_container_tracking(container_name,ctype,event_name) 
      when 'stop'
    inform_container_tracking(container_name,ctype,event_name) 
      when 'pause'  
    inform_container_tracking(container_name,ctype,event_name) 
      when 'unpause'
    inform_container_tracking(container_name,ctype,event_name) 
      when 'create'
    inform_container_tracking(container_name,ctype,event_name) 
      when 'destroy'
    inform_container_tracking(container_name,ctype,event_name) 
      when 'killed'
    inform_container_tracking(container_name,ctype,event_name) 
  else
    SystemDebug.debug(SystemDebug.container_events, 'Untracked event',event_name,c_name,ctype )
    tracked = false
     end  
end

def inform_container_tracking(container_name,ctype,event_name)
  c = get_event_container(container_name,ctype)
  c.task_at_hand(event_name)
  inform_container_monitor(container_name,ctype,event_name) 
end

def get_event_container(container_name,ctype)
  c = container_from_cache(container_name)   
     if c.nil?
       c = loadManagedEngine(container_name)  if ctype == 'container'
       c = loadManagedService(container_name)  if ctype == 'service'
     end
       return false if c.nil?
      return c
end

 def inform_container(container_name,ctype,event_name)
   SystemDebug.debug(SystemDebug.container_events, 'recevied inform_container',container_name,event_name)
    c = get_event_container(container_name,ctype)
   return false if c.is_a?(FalseClass)
   SystemDebug.debug(SystemDebug.container_events, 'informed _container',container_name,event_name)
    c.process_container_event(event_name)
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