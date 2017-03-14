require_relative 'engines_docker_api_error.rb'

module EnginesDockerApiErrors
  def log_warn_mesg(mesg,*objs)
     EnginesDockerApiError.new(mesg.to_s,:warning)
  end

  def log_error_mesg(mesg,*objs)
    super
     EnginesDockerApiError.new(mesg.to_s,:failure)
  end

  def log_exception(e,*objs)
    super
     EnginesDockerApiError.new(e.to_s,:exception)
  end

end