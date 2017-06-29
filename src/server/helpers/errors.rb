
def error_hash(mesg, *params)
  {
    error_type: :error,
    params: params,
    source: caller[1..4],
    system: 'api',
    error_mesg: mesg
  }
end

def send_encoded_exception(api_exception)#request, error_object, *args)
  api_exception[:exception] = fake_exception(api_exception) unless api_exception[:exception].is_a?(Exception)
  status_code = 404
  status_code = api_exception[:status] if api_exception.key?(:status)

  if request.is_a?(String)
    error_mesg = {
      route: request,
      error_object: {}
    }
  else
    error_mesg = {
      route: request.fullpath,
      method: request.request_method,
      query: request.query_string,
      params: request.params,
      error_object: {}
    }
  end
  STDERR.puts('send_encoded_exception with request ' + api_exception.to_s)
  if api_exception[:exception].is_a?(EnginesException)
    error_mesg[:error_object] = api_exception[:exception].to_h
    error_mesg[:params] = api_exception[:params].to_s
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
  #  send_encoded_exception(request: 'send_encoded_exception', exception: e, status: 500)
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