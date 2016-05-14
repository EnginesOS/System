module DockerEvents
  require '/opt/engines/lib/ruby/api/system/docker/docker_api/docker_event_watcher.rb'

  def container_event(event_hash)
    STDERR.puts(event_hash.to_s)
#    status = event_hash['status']
#       s = status.split(':')
#       if s.count > 1
#         event_name = s[0]
#         data = status
#       else
#         event_name = status
#         data = nil
#       end
#  SystemDebug.debug(SystemDebug.container_events, 'c name:',event_hash['from'],'event type:',event_name)    
#       return false if event_name.nil?
#       return true if event_name.start_with?('exec_')
#       
#   unless event_hash.key?('from')
#    #p :container_event
#    
#    id = event_hash['id']
#     c_name = container_name_from_id(id)
#     SystemDebug.debug(SystemDebug.container_events, ' from looking up by id', c_name, event_hash)
#   else   
#        container_name = event_hash['from'].to_s
#     if container_name.start_with?('engines/')    
#       c_name = container_name.sub(/engines\//,'')
#        c_name.sub!(/:.*/,'')
#        ctype = 'service'
#      else    
#        ctype = 'container'
#        c_name = container_name
#      end 
#    unless File.exist?(SystemConfig.RunDir + '/' + ctype + 's/' + c_name + '/running.yaml')
#      id = event_hash['id']     
#      c_name = container_name_from_id(id)
#      SystemDebug.debug(SystemDebug.container_events, ' from looking up by id because no file', c_name, event_hash)
#    end    
#  end 
    event_hash['container_name'] = container_name_from_id(event_hash['id']) unless File.exist?(SystemConfig.RunDir + '/' + event_hash['container_type'] + 's/' + event_hash['container_name'] + '/running.yaml')
   return no_container(event_hash) unless File.exist?(SystemConfig.RunDir + '/' + event_hash['container_type'] + 's/' + event_hash['container_name'] + '/running.yaml')
#  return false if c_name.nil?
#  ctype = 'container' if ctype.nil?
#   unless  File.exist?(SystemConfig.RunDir + '/' + ctype + 's/' + c_name + '/running.yaml')            
#     SystemDebug.debug(SystemDebug.container_events, 'no container file',SystemConfig.RunDir + '/' + ctype + 's/' + c_name + '/running.yaml', event_hash)
#     return false  # unless event_name == 'create'
#   end
#  tracked = true
  inform_container(event_hash['container_name'] ,event_hash['container_type'] ,event_hash['status'],event_hash)
  
  case event_hash['status']
      when 'start'
    inform_container_tracking(event_hash['container_name'] ,event_hash['container_type'] ,event_hash['status']) 
      when 'stop'
    inform_container_tracking(event_hash['container_name'] ,event_hash['container_type'] ,event_hash['status']) 
      when 'pause'  
    inform_container_tracking(event_hash['container_name'] ,event_hash['container_type'] ,event_hash['status']) 
      when 'unpause'
    inform_container_tracking(event_hash['container_name'] ,event_hash['container_type'] ,event_hash['status']) 
      when 'create'
    inform_container_tracking(event_hash['container_name'] ,event_hash['container_type'] ,event_hash['status']) 
      when 'destroy'
    inform_container_tracking(event_hash['container_name'] ,event_hash['container_type'] ,event_hash['status']) 
      when 'killed'
    inform_container_tracking(event_hash['container_name'] ,event_hash['container_type'] ,event_hash['status']) 
  else
    SystemDebug.debug(SystemDebug.container_events, 'Untracked event',event_name,c_name,ctype )
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
end