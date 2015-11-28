module DockerEvents
require '/opt/engines/lib/ruby/api/system/docker/docker_api/docker_event_watcher.rb'


     def container_event(hash)
       event_name = hash.to_s
       puts hash['from'].to_s + ' had event ' +  event_name 
            p :__
       c = container_from_cache(hash['from'],event_name)
         return nil if c.nil?
       c.expire_info
       case event_name
       when 'stop'
       when 'pause'
       when 'create'
       when ''
       end
       
     end

     
  def start_docker_event_listener
    docker_event_listener = DockerEventWatcher.new(self)
    Thread.new {  docker_event_listener.start}
  end
  
end