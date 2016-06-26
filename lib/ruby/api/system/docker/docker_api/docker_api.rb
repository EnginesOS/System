class DockerApi  < ErrorsApi

  require_relative 'docker_connection.rb'

  require_relative 'docker_api_errors.rb'
  include EnginesDockerApiErrors

  require_relative 'docker_api_exec.rb'
  include DockerApiExec

  require_relative 'docker_api_container_actions.rb'
  include DockerApiContainerActions
  require_relative 'docker_api_container_status.rb'
  include DockerApiContainerStatus

  require_relative 'docker_api_images.rb'
  include DockerApiImages
  
  require_relative 'docker_api_container_ops.rb'
  include DockerApiContainerOps
  
  def initialize
    @con = DockerConnection.new
  rescue StandardError =>e
    log_exception(e)
  end

  def get_event_stream(handler,filter=nil )
    @con.request_stream('/events',filter,handler)
  rescue StandardError =>e
    log_exception(e)
  end

  #
  # def create_container(container)
  #   params = create_options(container)
  #   SystemDebug.debug(SystemDebug.containers,  params.to_s)
  #
  #
  # end

end