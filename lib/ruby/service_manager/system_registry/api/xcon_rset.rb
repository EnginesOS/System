require '/opt/engines/lib/ruby/exceptions/registry_exception.rb'
require 'ffi_yajl'

def json_parser
  @json_parser ||= FFI_Yajl::Parser.new({:symbolize_keys => true})
end

def headers (content_type = nil)
  @headers = {'content_type' => 'application/json','ACCESS_TOKEN' => 'atest_randy', 'Accept' => '*/*'} if @headers.nil?
  @headers['content_type'] = content_type unless content_type.nil?
  @headers
end

def connection(content_type = nil)
  # STDERR.puts('open connec' )
  @connection =  Excon.new(base_url,
  debug_request:  true,
  debug_response: true,
  ssl_verify_peer: false,
  persistent: true, #was false when threaded
  headers: headers(content_type) ) if @connection.nil?
  @connection
rescue Errno::EHOSTUNREACH
  @core_api.fix_registry_problem
  retry
rescue StandardError => e
  raise EnginesException.new(error_hash('Failed to open base url to registry ' + e.to_s, @base_url.to_s))
end

def close_connection
  #  @connection.reset unless @connection.nil?
  #  @connection = nil
end

def reopen_connection
  # STDERR.puts('re open connec')
  @connection.reset unless @connection.nil?
  @connection = nil
  @connection = connection
  @connection
end

def rest_get(path, params = nil, time_out = 120, _headers = nil)
  cnt = 0
  q = query_hash(params)
  STDERR.puts(' REG GET ' + path.to_s + '?' + q.to_s )
 # SystemDebug.debug(SystemDebug.registry,'GET ', path.to_s + '?' + q.to_s)
  lheaders = headers
  lheaders.merge(_headers) unless _headers == nil
  lheaders.delete('Content-Type' ) if q.nil?
  req = {time_out: time_out, method: :get, path: @route_prefix.to_s + path.to_s, headers: lheaders }
STDERR.puts(' REG GET ' + req.to_s)
  req[:query] = q unless q.nil?
  r = connection.request(req)
  close_connection
  parse_xcon_response(r)
rescue Excon::Error::Socket => e
  #STDERR.puts(e.class.name + 'Excon::Error::Socket error:' + e.socket_error.to_s)
  #unless e.socket_error == EOFError #'end of file reached'
  reopen_connection
  #STDERR.puts(e.class.name + 'Excon::Error::Socket with path:' + path.to_s + "\n" + 'params:' + q.to_s + ':::' + req.to_s  + ':' + e.to_s)
  cnt += 1
  retry if cnt < 5
  #end
rescue StandardError => e
  close_connection
  raise EnginesException.new(error_hash('reg exception ' + e.to_s, @base_url.to_s))
end

def time_out
  120
end

def rest_post(path, params = nil, lheaders = nil)
  cnt = 0
  begin
   # SystemDebug.debug(SystemDebug.registry,'POST  ', path.to_s + '?' + params.to_s)
    lheaders = headers if lheaders.nil?
    r = parse_xcon_response(connection.request({read_timeout: time_out, headers: lheaders, method: :post, path: @route_prefix.to_s + path.to_s, body: query_hash(params).to_json }))
    close_connection
    r
  rescue Excon::Error::Socket => e
    unless e.socket_error == EOFError
      #  STDERR.puts e.class.name
      reopen_connection
      cnt += 1
      retry if cnt < 5
    end
  rescue StandardError => e
    STDERR.puts('BASE ur ' + @base_url.to_s)
    STDERR.puts('path ' + path.to_s)
    STDERR.puts('exception ' + e.to_s)
    close_connection

    raise EnginesException.new(error_hash('reg exception ' + path.to_s + "\n" + e.to_s, @base_url.to_s))
  end
end

def rest_put(path, params = nil, lheaders = nil)
  cnt = 0
 # SystemDebug.debug(SystemDebug.registry,'Delete ', path.to_s + '?' + params.to_s)
  lheaders = headers if lheaders.nil?
  r = parse_xcon_response( connection.request(read_timeout: time_out, headers: lheaders, method: :put, path: @route_prefix + path.to_s, query: query_hash(params).to_json ))
  close_connection
  r
rescue Excon::Error::Socket => e
  # unless e.socket_error == EOFError
  #  STDERR.puts e.class.name
  reopen_connection
  cnt += 1
  retry if cnt < 5
  # end
rescue StandardError => e
  close_connection
  raise EnginesException.new(error_hash('reg exception ' + e.to_s, @base_url.to_s))
end

def query_hash(params)
  if params.nil?
    nil
  elsif params.key?(:params)
    params[:params]
  else
    params
  end
end

def rest_delete(path, params = nil, lheaders = nil)
  cnt = 0
  q = query_hash(params)
 # SystemDebug.debug(SystemDebug.registry, 'DEL ', path.to_s + '?' + q.to_s)
  lheaders = headers if lheaders.nil?
  r = parse_xcon_response( connection.request(read_timeout: time_out, headers: lheaders, method: :delete, path: @route_prefix + path.to_s, query: q))
  close_connection
  r

rescue Excon::Error::Socket => e
  #  unless e.socket_error == EOFError
  # STDERR.puts e.class.name
  reopen_connection
  cnt += 1
  retry if cnt < 5
  #  end
rescue StandardError => e
  raise EnginesException.new(error_hash('reg exception ' + e.to_s, @base_url.to_s))
ensure
  close_connection
  #end
end

private
#

def parse_xcon_response(resp)
  raise RegistryException.new({status: 500, error_mesg: 'Server Error', exception: :exception})  if resp.nil?
  # STDERR.puts('1 ' + resp.status.to_s + ':' + resp.headers.to_s + " __ " + resp.body.to_s)
  error_result_exception(resp) if resp.status > 399
  r = resp.body
  unless r.nil?
    r.strip!
    unless resp.headers['Content-Type'] == 'plain/text'
      r = json_parser.parse(r)
      r = r[:BooleanResult] if r.is_a?(Hash) && r.key?(:BooleanResult)
    end
  end
  r
end

def error_result_exception(resp)
  # STDERR.puts('Registry Exception ' + resp.body.to_s  + ' head ' + resp.headers.to_s  )   unless resp.nil?
  raise RegistryException.new(
  {status: resp.status,
    error_type: :error,
    error_mesg: 'Route Not Found',
    params: resp.body
  }) if resp.headers.nil? || resp.headers['Content-Type'] != 'application/json'
  begin
    r = json_parser.parse(resp.body)
  rescue
    r = {}
  end
  r = {} unless r.is_a?(Hash)
  r[:status] = resp.status if r.is_a?(Hash)

  # STDERR.puts('Registry Exception from json result ' + r.to_s )

  raise RegistryException.new(
  {status: 403,
    error_type: :warning,
    error_mesg: 'RegistryException',
    params: 'nil'
  }) if resp.nil?
  # STDERR.puts('Registry Exception from R ' )
  raise RegistryException.new(r)
end

def base_url
 r = 'http://' + @core_api.registry_root_ip + ':4567'
    STDERR.puts('REG base ' + r.to_s)
    r
rescue  StandardError => e
  raise EnginesException.new('Cannot Deterine Base URL' + e.to_s)
end

