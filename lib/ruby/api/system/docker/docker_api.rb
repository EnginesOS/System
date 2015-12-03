class DockerApi < ErrorsApi
  require_relative 'docker_cmd_options'

  require_relative 'docker_images.rb'
  include DockerImages
  
  require_relative 'docker_container_status.rb'
  include DockerContainerStatus
  
  require_relative 'docker_container_actions.rb'
   include DockerContainerActions
 
  require_relative 'docker_api/docker_connection.rb'
  def initialize()
  @docker_comms = DockerConnection.new
  end 

end
