module DockerEvents
  require '/opt/engines/lib/ruby/api/system/docker/docker_api/docker_event_watcher.rb'

  def container_event(hash)
    p :container_event
    p hash
    status = hash['status']
    s = status.split(':')
    if s.count > 1
      event_name = s[0]
      data = status
    else
      event_name = status
      data = nil
    end
  container_name = hash['from'].to_s

  if container_name.start_with?('engines/')    
   c_name = container_name.sub(/engines/,'services')
    c_name.sub!(/:.*/,'')
    ctype = 'service'
  else    
    ctype = 'container'
    c_name = container_name
  end 
   
  case event_name
      when 'start'
    inform_container(c_name,event_name)
      when 'stop'
    inform_container(c_name,event_name)
      when 'pause'  
    inform_container(c_name,event_name)
      when 'unpause'
    inform_container(c_name,event_name)
      when 'create'
    inform_container(c_name,event_name)
      when 'destroy'
    inform_container(c_name,event_name)

     end
     
  inform_container_monitor(container_name,ctype,event_name) #unless event_name.start_with?('exec_')
end
 def inform_container(container_name,event_name)
   puts container_name + ' had event ' +  event_name
   p :__

    c = container_from_cache(container_name)
    
    return nil if c.nil?
    p :Event_on
    p c.container_name
    c.task_complete(event_name)
   
      
  rescue StandardError =>e
    log_exception(e)
  end

  def start_docker_event_listener
    docker_event_listener = DockerEventWatcher.new(self)
    Thread.new {  docker_event_listener.start}

  rescue StandardError =>e
    log_ecxception(e)

  end
end