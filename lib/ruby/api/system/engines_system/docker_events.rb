module DockerEvents
  require '/opt/engines/lib/ruby/api/system/docker/docker_api/event_watcher/docker_event_watcher.rb'

  def  fill_in_event_system_values(event_hash)
    cn_and_t = @engines_api.container_name_and_type_from_id(event_hash['id'])
    return cn_and_t if cn_and_t.is_a?(EnginesError) 
    return log_error_mesg('cn_and_t Not an array' + cn_and_t.to_s + ':' +  cn_and_t.class.name) unless cn_and_t.is_a?(Array)
    event_hash[:container_name] = cn_and_t[0]
    event_hash[:container_type] = cn_and_t[1]
    event_hash   
  end
  
  def container_event(event_hash)
    
    return log_error_mesg('Nil event hash passed to container event','') if event_hash.nil?
   
    STDERR.puts('1 CONTAINER EVENTS' + event_hash.to_s)
   
    
    r = fill_in_event_system_values(event_hash)
    return r if r.is_a?(EnginesError) 
    STDERR.puts('2 CONTAINER EVENTS' + event_hash.to_s)
#    event_hash[:container_name] = container_name_from_id(event_hash['id']) unless event_hash.key?('container_name')
#    STDERR.puts('2 CONTAINER EVENTS' + event_hash.to_s)
#    event_hash[:container_name] = container_name_from_id(event_hash['id']) if event_hash[:container_name].nil?
#    STDERR.puts('3 CONTAINER EVENTS' + event_hash.to_s)
#    event_hash[:container_name].gsub!(/:.*$/,'')
#    STDERR.puts('4 CONTAINER EVENTS' + event_hash.to_s)
#    event_hash[:container_name] = container_name_from_id(event_hash['id']) unless File.exist?(SystemConfig.RunDir + '/' + event_hash[:container_type].to_s + 's/' + event_hash[:container_name].to_s + '/config.yaml')
#    STDERR.puts('5 CONTAINER EVENTS' + event_hash.to_s + ' ' + SystemConfig.RunDir + '/' + event_hash[:container_type].to_s + 's/' + event_hash[:container_name].to_s + '/config.yaml')
#    return no_container(event_hash) if event_hash[:container_name].nil?
    if event_hash[:container_type] == 'service' ||  event_hash[:container_type] == 'system_service'
      # Enable Cold load of service from config.yaml
    return no_container(event_hash) unless File.exist?(SystemConfig.RunDir + '/' + event_hash[:container_type] + 's/' + event_hash[:container_name] + '/config.yaml') 
    else
      # engines always have a running.yaml
   return no_container(event_hash) unless File.exist?(SystemConfig.RunDir + '/' + event_hash[:container_type] + 's/' + event_hash[:container_name] + '/running.yaml')
    end

  inform_container(event_hash[:container_name] ,event_hash[:container_type] ,event_hash[:status],event_hash)
  
  case event_hash[:status]
      when 'start'
    inform_container_tracking(event_hash[:container_name] ,event_hash[:container_type] ,event_hash[:status]) 
    when 'oom'
       inform_container_tracking(event_hash[:container_name] ,event_hash[:container_type] ,event_hash[:status]) 
      when 'stop'
    inform_container_tracking(event_hash[:container_name] ,event_hash[:container_type] ,event_hash[:status]) 
      when 'pause'  
    inform_container_tracking(event_hash[:container_name] ,event_hash[:container_type] ,event_hash[:status]) 
      when 'unpause'
    inform_container_tracking(event_hash[:container_name] ,event_hash[:container_type] ,event_hash[:status]) 
      when 'create'
    inform_container_tracking(event_hash[:container_name] ,event_hash[:container_type] ,event_hash[:status]) 
      when 'destroy'
    inform_container_tracking(event_hash[:container_name] ,event_hash[:container_type] ,event_hash[:status]) 
      when 'killed'
    inform_container_tracking(event_hash[:container_name] ,event_hash[:container_type] ,event_hash[:status]) 
    when 'die'
       inform_container_tracking(event_hash[:container_name] ,event_hash[:container_type] ,event_hash[:status])  
  else
    SystemDebug.debug(SystemDebug.container_events, 'Untracked event',event_name.to_s,c_name.to_s,ctype.to_s )
    tracked = false
     end  
     
    rescue StandardError => e
      
       log_exception(e, event_hash)

end

def no_container(event_hash)
  #FIXME track non system containers here
  #use to clear post build crash
  #alert if present when not building
  return true
end
def inform_container_tracking(container_name,ctype,event_name)
  SystemDebug.debug(SystemDebug.container_events, 'inform_container_tracking',container_name,ctype,event_name)
  c = get_event_container(container_name,ctype)
  c.task_complete(event_name) unless c.is_a?(FalseClass)
  inform_container_monitor(container_name,ctype,event_name)
  rescue StandardError =>e
     log_exception(e)

end

def get_event_container(container_name,ctype)
  c = container_from_cache(container_name)   
     if c.nil?
       c = loadManagedEngine(container_name)  if ctype == 'container'
       c = loadManagedService(container_name)  if ctype == 'service'
     end
       return false if c.nil?
      return c
  rescue StandardError =>e
     log_exception(e)

end

 def inform_container(container_name,ctype,event_name,event_hash)
   SystemDebug.debug(SystemDebug.container_events, 'recevied inform_container',container_name,event_name)
    c = get_event_container(container_name,ctype)
   return false if c.is_a?(FalseClass)
   SystemDebug.debug(SystemDebug.container_events, 'informed _container',container_name,event_name)
    c.process_container_event(event_name,event_hash)
  return true
  rescue StandardError =>e
    log_exception(e)
  end

  def start_docker_event_listener
    docker_event_listener = DockerEventWatcher.new()
    Thread.new {  docker_event_listener.start}
    docker_event_listener
  rescue StandardError =>e
    log_exception(e)

  end
  def add_event_listener(listener,mask, container_id = nil )
     @docker_event_listener.add_event_listener(listener,mask, container_id )
  end
  def rm_event_listener(listener)
      @docker_event_listener.rm_event_listener(listener)
   end
end