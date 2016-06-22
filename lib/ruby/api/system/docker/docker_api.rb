class DockerApi < ErrorsApi
  require_relative 'docker_errors.rb'
  require_relative 'docker_cmd_options'
  require_relative 'engines_docker_error.rb'

  require_relative 'docker_images.rb'
  include DockerImages
  
  require_relative 'docker_container_status.rb'
  include DockerContainerStatus
  
  require_relative 'docker_container_actions.rb'
   include DockerContainerActions
  require_relative 'docker_container_actions.rb'
  require_relative 'docker_errors.rb'
  include DockerErrors
  require_relative 'docker_api/docker_connection.rb'
  def initialize()
  @docker_comms = DockerConnection.new
  end 
  def docker_exec(container, command, log_error = true)
    @docker_comms.docker_exec(container, command, log_error)
  end
end
