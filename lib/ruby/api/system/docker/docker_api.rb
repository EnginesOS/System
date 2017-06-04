class DockerApi < ErrorsApi
  require_relative 'docker_errors.rb'
  require '/opt/engines/lib/ruby/exceptions/docker_exception.rb'
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

  def docker_exec(params)
    @docker_comms.docker_exec(params)
  end

  def container_name_and_type_from_id(id)
    @docker_comms.container_name_and_type_from_id(id)
  end

  def build_engine(engine_name, build_archive_filename, builder)
    @docker_comms.build_engine(engine_name, build_archive_filename, builder)
  end
end
