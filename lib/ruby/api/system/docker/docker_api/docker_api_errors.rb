require_relative 'engines_docker_api_error.rb'

module EnginesDockerApiErrors
  def log_warn_mesg(mesg, *objs)
    EnginesDockerApiError.new(mesg.to_s, :warning)
  end

  def log_error_mesg(mesg, *objs)
    super
    EnginesDockerApiError.new(mesg.to_s, :failure)
  end

  def log_exception(e, *objs)
    super
    EnginesDockerApiError.new(e.to_s,:exception)
  end

  def error_hash(res, params, status)
    r = error_type_hash(mesg, params)
    r[:error_type] = :error
    r[:status] = status
    r
  end

  def docker_error_hash(res, params = nil)
    status = nil
 #   STDERR.puts('DOCKER error HASH' + res.to_s + ':' + params.to_s)
    if res.is_a?(String)
      e = res
    elsif  res.nil?
      e =  ''
    else
      begin
        e = res.body 
        status = res.status
      rescue
        e = e.to_s
      end
    end
    r = error_type_hash(e, params)
    r[:status] = status unless status.nil?
    r[:error_type] = :error
    r
  end

  def warning_hash(mesg, params = nil)
    r = error_type_hash(mesg, params)
    r[:error_type] = :warning
    r
  end

  def error_type_hash(mesg, params = nil)
    {error_mesg: mesg,
      system: :docker_api,
      params: params }
  end
end