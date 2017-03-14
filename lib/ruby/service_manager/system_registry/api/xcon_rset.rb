#require 'rest-client'

def json_parser
  @json_parser ||= FFI_Yajl::Parser.new({:symbolize_keys => true})
end

def headers (content_type = nil)
  @headers = {'content_type' => 'application/json','ACCESS_TOKEN' => 'atest_randy', 'Accept' => '*/*'} if @headers.nil?
  @headers['content_type'] = content_type unless content_type.nil?
  @headers
end

def connection(content_type = nil)
  @connection ||=  Excon.new(base_url,
  :debug_request => true,
  :debug_response => true,
  :ssl_verify_peer => false,
  :persistent => true,
  :headers => headers)
rescue StandardError => e
  STDERR.puts('Failed to open base url to registry' + @base_url.to_s)
  STDERR.puts e.backtrace.to_s
  log_exception(e, params, path)
end

def reopen_connection
  @connection.reset
  @connection = Excon.new(base_url,
  debug_request: true,
  debug_response: true,
  ssl_verify_peer: false,
  persistent: true,
  headers: headers)
  @connection
end

def rest_get(path,params = nil,time_out=120, _headers = nil)
  cnt = 0
  q = query_hash(params)
  #STDERR.puts(' REG GET ' + path.to_s + '?' + q.to_s )
  SystemDebug.debug(SystemDebug.registry,'GET ', path.to_s + '?' + q.to_s)
  lheaders = headers
  lheaders.merge(_headers) unless _headers == nil
  lheaders.delete('Content-Type' ) if  q.nil?
  req = {time_out: time_out, method: :get, path: @route_prefix + path, headers: lheaders }
  req[:query] = q unless q.nil?
  r = connection.request(req)
  parse_xcon_response(r)
rescue  Excon::Error::Socket => e
  reopen_connection
  STDERR.puts e.class.name + ' with path:' + path.to_s + "\n" + 'params:' + q.to_s + ':::' + req.to_s  + ':' + e.to_s
  cnt+=1
  retry if cnt< 5
end

def time_out
  120
end

def rest_post(path,params = nil, lheaders=nil)
  begin
    SystemDebug.debug(SystemDebug.registry,'POST  ', path.to_s + '?' + params.to_s)
    lheaders = headers if lheaders.nil?
  r = parse_xcon_response(connection.request({read_timeout: time_out, headers: lheaders, method: :post, path: @route_prefix + path, body: query_hash(params).to_json }))
    return r
  rescue   Excon::Error::Socket => e
    reopen_connection
    retry
  end
end

def rest_put(path,params = nil, lheaders=nil)
  SystemDebug.debug(SystemDebug.registry,'Delete ', path.to_s + '?' + params.to_s)
  lheaders = headers if lheaders.nil?
  r = parse_xcon_response( connection.request(read_timeout: time_out, headers: lheaders, method: :put, path: @route_prefix + path, query: query_hash(params).to_json ))
  return r
rescue Excon::Error::Socket => e
  reopen_connection
  retry
end

def query_hash(params)
  return if params.nil?
  params[:params] if params.key?(:params)
  params
end

def rest_delete(path, params = nil, lheaders=nil)
  q = query_hash(params)
  SystemDebug.debug(SystemDebug.registry,'DEL ', path.to_s + '?' + q.to_s)
  lheaders = headers if lheaders.nil?
  r =  parse_xcon_response( connection.request(read_timeout: time_out, headers: lheaders, method: :delete, path: @route_prefix + path, query: q))
  return r
rescue Excon::Error::Socket => e
  reopen_connection
  retry
  #end
end

private
#


def parse_xcon_response(resp)
  raise RegistryException.new({status: 500 , error_mesg: 'Server Error', exception: :exception})  if resp.nil?
# STDERR.puts('1 ' + resp.status.to_s + ':' + resp.headers.to_s + " __ " + resp.body.to_s)
  if resp.status > 399
    raise RegistryException.new(
    {status: resp.status,
      error_type: :error,
      error_mesg: 'Route Not Found',
      params: resp.body
    }) if resp.headers.nil? || !  resp.headers['Content-Type'] == 'application/json'
    r = deal_with_json(resp.body)
    r = {} if r.nil?
    r[:status] = resp.status
    raise RegistryException.new(r)
  end
#  STDERR.puts('2 ' + resp.status.to_s + ':' + resp.body.to_s)
  #return parse_error(resp) if resp.status > 399
  r = resp.body
  return if r.nil?
  r.strip!
  return r if resp.headers['Content-Type'] == 'plain/text'
  r = deal_with_json(r)
  r = r[:BooleanResult] if r.is_a?(Hash) && r.key?(:BooleanResult)
  #STDERR.puts( resp.status.to_s + ':' + r.class.name)
  r
end

def base_url
  'http://' + @core_api.get_registry_ip + ':4567'
rescue  StandardError => e
  log_exception(e)
end

