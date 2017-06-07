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
  @connection ||=  Excon.new(base_url,
  debug_request:  true,
  debug_response: true,
  ssl_verify_peer: false,
  persistent: true,
  headers: headers)
rescue Errno::EHOSTUNREACH
  @core_api.fix_registry_problem
  retry
rescue StandardError => e
  raise EnginesException.new(error_hash('Failed to open base url to registry ' + e.to_s, @base_url.to_s))
end

def reopen_connection
  # STDERR.puts('re open connec' )
  @connection.reset
  @connection = nil
  @connection = connection
  @connection
end

def rest_get(path,params = nil, time_out = 120, _headers = nil)
  cnt = 0
  q = query_hash(params)
  #STDERR.puts(' REG GET ' + path.to_s + '?' + q.to_s )
  SystemDebug.debug(SystemDebug.registry,'GET ', path.to_s + '?' + q.to_s)
  lheaders = headers
  lheaders.merge(_headers) unless _headers == nil
  lheaders.delete('Content-Type' ) if q.nil?
  req = {time_out: time_out, method: :get, path: @route_prefix + path.to_s, headers: lheaders }
  req[:query] = q unless q.nil?
  r = connection.request(req)
  parse_xcon_response(r)
rescue  Excon::Error::Socket => e
  reopen_connection
  STDERR.puts(e.class.name + ' with path:' + path.to_s + "\n" + 'params:' + q.to_s + ':::' + req.to_s  + ':' + e.to_s)
  cnt+=1
  retry if cnt< 5
rescue StandardError => e
  raise EnginesException.new(error_hash('reg exception ' + e.to_s, @base_url.to_s))
end

def time_out
  120
end

def rest_post(path, params = nil, lheaders = nil)
  begin
    SystemDebug.debug(SystemDebug.registry,'POST  ', path.to_s + '?' + params.to_s)
    lheaders = headers if lheaders.nil?
    parse_xcon_response(connection.request({read_timeout: time_out, headers: lheaders, method: :post, path: @route_prefix + path.to_s, body: query_hash(params).to_json }))
  rescue Excon::Error::Socket => e
    STDERR.puts e.class.name
    reopen_connection
    retry
  rescue StandardError => e
    raise EnginesException.new(error_hash('reg exception ' + path.to_s + "\n" + e.to_s, @base_url.to_s))
  end
end

def rest_put(path, params = nil, lheaders = nil)
  SystemDebug.debug(SystemDebug.registry,'Delete ', path.to_s + '?' + params.to_s)
  lheaders = headers if lheaders.nil?
  r = parse_xcon_response( connection.request(read_timeout: time_out, headers: lheaders, method: :put, path: @route_prefix + path.to_s, query: query_hash(params).to_json ))
  r
rescue Excon::Error::Socket => e
  STDERR.puts e.class.name
  reopen_connection
  retry
rescue StandardError => e
  raise EnginesException.new(error_hash('reg exception ' + e.to_s, @base_url.to_s))
end

def query_hash(params)
  return if params.nil?
  params[:params] if params.key?(:params)
  params
end

def rest_delete(path, params = nil, lheaders = nil)
  q = query_hash(params)
  SystemDebug.debug(SystemDebug.registry, 'DEL ', path.to_s + '?' + q.to_s)
  lheaders = headers if lheaders.nil?
  r = parse_xcon_response( connection.request(read_timeout: time_out, headers: lheaders, method: :delete, path: @route_prefix + path.to_s, query: q))
  r
rescue Excon::Error::Socket => e
  STDERR.puts e.class.name
  reopen_connection
  retry
rescue StandardError => e
  raise EnginesException.new(error_hash('reg exception ' + e.to_s, @base_url.to_s))
  #end
end

private
#

def parse_xcon_response(resp)
  raise RegistryException.new({status: 500, error_mesg: 'Server Error', exception: :exception})  if resp.nil?
  # STDERR.puts('1 ' + resp.status.to_s + ':' + resp.headers.to_s + " __ " + resp.body.to_s)
  error_result_exception(resp) if resp.status > 399
  r = resp.body
  return if r.nil?
  r.strip!
  return r if resp.headers['Content-Type'] == 'plain/text'
  r = json_parser.parse(r)
  r = r[:BooleanResult] if r.is_a?(Hash) && r.key?(:BooleanResult)
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
  {status: 404,
    error_type: :warning,
    error_mesg: 'Route Not Found',
    params: 'nil'
  }) if resp.nil?
  # STDERR.puts('Registry Exception from R ' )
  raise RegistryException.new(r)
end

def base_url
  'http://' + @core_api.registry_root_ip + ':4567'
rescue  StandardError => e
  raise EnginesException.new('Cannot Deterine Base URL' + e.to_s)
end

