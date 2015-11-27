class DockerApi < ErrorsApi
  require_relative 'docker_cmd_options'
  require_relative 'docker_event_listener.rb'
  include DockerEventListener 
  
  require_relative 'docker_images.rb'
  include DockerImages
  
  require_relative 'docker_container_status.rb'
  include DockerContainerStatus
  
  require_relative 'docker_container_actions.rb'
   include DockerContainerActions
 
  

  

end
