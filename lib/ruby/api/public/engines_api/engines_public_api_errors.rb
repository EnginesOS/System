require_relative 'engines_public_api_error.rb'

module EnginesPublicApiErrors
  def log_warn_mesg(mesg,*objs)
    EnginesPublicApiError.new(mesg.to_s,:warning)
  end

  def log_error_mesg(mesg,*objs)
    super
    EnginesPublicApiError.new(mesg.to_s,:failure)
  end

  def log_exception(e,*objs)
    super
    EnginesPublicApiError.new(e.to_s,:exception)
  end
end