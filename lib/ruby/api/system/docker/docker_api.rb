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
  
  def test_inspect_container(container)
    r = @docker_comms.test_inspect(container)
    p :test_docker
    p r.class.name.to_s
    p r.to_s
    r
  end
  
  

end
