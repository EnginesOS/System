module DockerEvents
require '/opt/engines/lib/ruby/api/docker/docker_api/docker_event_watcher.rb'


     def container_event(hash)
       puts hash['from'].to_s + ' had event ' +  event_name 
            p :__
     end

     
  def start_docker_event_listener
    docker_event_listener = DockerEventWatcher.new(self)
    docker_event_listener.start
  end
  
end