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
  case event_name
      when 'start'
      when 'stop'
      when 'pause'  
      when 'unpause'
      when 'create'
      when 'destroy'
      
     else
       return 
     end

    puts hash['from'].to_s + ' had event ' +  event_name
    p :__
    container_name = hash['from']

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