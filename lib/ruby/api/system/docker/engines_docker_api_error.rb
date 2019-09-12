class EnginesDockerApiError < EnginesError
  def initialize(message, type = :fail)
    super
    @source = caller[1,4].to_s
    @sub_system = 'docker_api'
  end
end