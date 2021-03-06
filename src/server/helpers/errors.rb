def error_hash(mesg, *params)
  {
    error_type: :error,
    params: params,
    source: caller[1..4],
    system: 'api',
    error_mesg: mesg
  }
end

def warning_hash(mesg, params = nil)
  r = error_hash(mesg, params)
  r [:error_type] = :warning
  r
end

def send_encoded_exception(api_exception)#request, error_object, *args)
  api_exception[:exception] = fake_exception(api_exception) unless api_exception[:exception].is_a?(Exception)
  if api_exception[:exception].is_a?(EnginesException)
    unless  api_exception[:exception].status.nil?
      status_code = api_exception[:exception].status
    else
      if api_exception[:exception].level == :warning
        status_code = 405
      else
        status_code = 406
      end
    end
  end
  status_code = api_exception[:status] if api_exception.key?(:status)
  status_code = 500 if status_code.nil?
  if request.is_a?(String)
    error_mesg = {
      route: request,
      error_object: {}
    }
  else
    error_mesg = {
      route: request.fullpath,
      method: request.request_method,
      # query: request.query_string, Dont this may be huge
      params: request.params,
      error_object: {}
    }
  end
  STDERR.puts('send_encoded_exception with request ' + api_exception.to_s)
  if api_exception[:exception].is_a?(EnginesException)
    STDERR.puts('EnginesException')
    error_mesg[:error_object] = api_exception[:exception].to_h
    error_mesg[:params] = api_exception[:params].to_s
    if error_mesg[:error_object].is_a?(Hash)
      if error_mesg[:error_object].key?(:status_code)
        status_code = error_mesg[:error_object][:status_code]
      elsif error_mesg[:error_object][:error_type] == :warning
        status_code = 409
      end
    end
    status_code = 500 if status_code.nil?
  elsif api_exception[:exception].is_a?(Exception)
    error_mesg[:error_object] = {error_mesg: api_exception[:exception].to_s, error_type: :failure}
    error_mesg[:source] = api_exception[:exception].backtrace.to_s
    #  error_mesg[:error_mesg] = api_exception[:exception].to_s
    status_code = 500
  elsif api_exception[:exception].to_s == 'unauthorised'
    status_code = 403
  end
  STDERR.puts error_mesg.to_s
  return_json(error_mesg, status_code)
rescue Exception => e
  STDERR.puts e.to_s + '  ' + e.backtrace.to_s
  status_code = 500
end

def fake_exception(api_exception)
  STDERR.puts('faking it' + api_exception.to_s)
  STDERR.puts(caller[0..10].to_s)
  if api_exception.to_s == 'unauthorised'
    status_code = 403
    STDERR.puts('faking unauthorised')
  else
    status_code = 404
  end
  status_code = api_exception[:status] if api_exception.key?(:status)
  error_mesg = {
    error_object: {}
  }
  if request.is_a?(String)
    error_mesg[:route] = request
  else
    error_mesg[:route] = request.fullpath
  end
  error_mesg[:error_object] = api_exception[:exception].to_s
  return_text(error_mesg, status_code)
end