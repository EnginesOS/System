class EnginesDockerApiError < EnginesError
  def initialize(message, type = :fail)
      super
      @source = caller[1].to_s 
      @sub_system = 'docker_api'
    end
end