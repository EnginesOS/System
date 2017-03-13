#require 'rest-client'
require_relative 'registry_exception.rb'

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
  STDERR.puts(' GET ' + path.to_s + '?' + q.to_s )
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

rescue StandardError => e
  STDERR.puts e.class.name + ' with path:' + path.to_s + "\n" + 'params:' + q.to_s + ':::' + req.to_s
  STDERR.puts e.backtrace.to_s
  log_exception(e, params, path)
  nil
end

def time_out
  120
end

def rest_post(path,params = nil, lheaders=nil)
  begin
    SystemDebug.debug(SystemDebug.registry,'POST  ', path.to_s + '?' + params.to_s)
    lheaders = headers if lheaders.nil?
    r = parse_xcon_response( connection.request(read_timeout: time_out, headers: lheaders, method: :post, path: @route_prefix + path, body: query_hash(params).to_json  ))
    return r
  rescue   Excon::Error::Socket => e
    reopen_connection
    retry
  rescue StandardError => e
    log_exception(e, params)
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
rescue StandardError => e
  log_exception(e, params)
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
rescue StandardError => e
  log_exception(e, params)
  #end
end

private

def parse_error(resp)
  r = resp.body
  r.strip!# (/^\n/,'')
  EnginesRegistryError.new(r)
rescue  StandardError => e
  STDERR.puts(e.to_s)
  STDERR.puts('Parse Error on error response object ', r.to_s)
  EnginesRegistryError.new(resp)

end

def parse_xcon_response(resp)
  raise RegistryException.new('Server Error', :exception)  if resp.nil?

  STDERR.puts( 'resp ' +  resp.body.to_s)
  rr = deal_with_jason(resp.body, create_additions: true)
  raise RegistryException.new(resp.status , rr)  if resp.status > 399

  #return parse_error(resp) if resp.status > 399
  r = resp.body
  return false if r.nil?
  r.strip!
  return true if r.to_s   == '' ||  r.to_s   == 'true'
  return false if r.to_s  == 'false'
  return nil if r.to_s  == 'null'
  hash = deal_with_jason(JSON.parse(r, create_additions: true))
  hash
rescue  StandardError => e
  STDERR.puts(e.to_s)
  STDERR.puts('Parse Error on error response object_' + r.to_s + '_')
  begin
    hash =  deal_with_jason(JSON.parse(r, create_additions: true))
    return hash
  rescue  Yajl::ParseError  => e
    STDERR.puts 'Yajl Failed to parse Registry response _' + r.to_s + '_'
    hash = deal_with_jason(JSON.parse(r, create_additions: true))
    STDERR.puts 'JSON parse as ' + hash.to_s + 'from' + r.to_s
    hash
  end
rescue  StandardError => e
  STDERR.puts e.class.name

  STDERR.puts e.backtrace
  STDERR.puts 'Failed to parse Registry response _' + r.to_s + '_'
  log_exception(e, r)
end

def base_url
  'http://' + @core_api.get_registry_ip + ':4567'
rescue  StandardError => e
  log_exception(e)
end

