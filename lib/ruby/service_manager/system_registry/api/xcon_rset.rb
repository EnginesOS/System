#require 'rest-client'


def json_parser
  @json_parser = FFI_Yajl::Parser.new({:symbolize_keys => true}) if @json_parser.nil?
  @json_parser
end

def headers (content_type = nil)
  @headers = {'content_type' => 'application/json','ACCESS_TOKEN' => 'atest_randy'} if @headers.nil?
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
  #  end
  #  @connection
rescue StandardError => e
  STDERR.puts('Failed to open base url to registry' + @base_url.to_s)  
  STDERR.puts e.backtrace.to_s
  log_exception(e, params, path)
end

def reopen_connection
  @connection.reset
#  STDERR.puts(' REOPEN connection ')
  @connection = Excon.new(base_url,
    :debug_request => true,
    :debug_response => true,
    :ssl_verify_peer => false,
    :persistent => true,
    :headers => headers)
  @connection
end

def rest_get(path,params = nil,time_out=120, _headers = nil)
  cnt = 0
  q = query_hash(params)
  
  STDERR.puts(' GET ' + path.to_s + '?' + q.to_s )
  SystemDebug.debug(SystemDebug.registry,'GET ', path.to_s + '?' + q.to_s)
#  headers = {'Content-Type' =>'application/json', 'Accept' => '*/*'} if headers.nil?
  #  q = {} if q.nil?
    lheaders = headers
    lheaders.merge(_headers) unless _headers == nil
  lheaders.delete('Content-Type' ) if  q.nil?
req = {:time_out => time_out,:method => :get,:path => @route_prefix + path, :headers => lheaders }
  req[:query] = q unless q.nil?

    r = connection.request(req)
  r = parse_xcon_response(r)
  return r
 rescue  Excon::Error::Socket => e

#  STDERR.puts(' eof ' + path.to_s + ':' + e.to_s + ':' + e.class.name + ':' + e.backtrace.to_s)
  reopen_connection
#STDERR.puts('retry CNT' + cnt.to_s + ':' + e.to_s)
  STDERR.puts e.class.name + ' with path:' + path.to_s + "\n" + 'params:' + q.to_s + ':::' + req.to_s  + ':' + e.to_s
cnt+=1
  retry if cnt< 5

rescue StandardError => e
  STDERR.puts e.class.name + ' with path:' + path.to_s + "\n" + 'params:' + q.to_s + ':::' + req.to_s
  STDERR.puts e.backtrace.to_s
  log_exception(e, params, path)

  {}
end


def time_out
  120
end

def rest_post(path,params = nil, headers=nil)
  begin
   # STDERR.puts(' POST ' + path.to_s )
    SystemDebug.debug(SystemDebug.registry,'POST  ', path.to_s + '?' + params.to_s)
    headers = {'Content-Type' =>'application/json', 'Accept' => '*/*'} if headers.nil?
    r = parse_xcon_response( connection.request(:read_timeout => time_out,:method => :post,:path => @route_prefix + path,:body => query_hash(params).to_json  ))
    return r
  rescue   Excon::Error::Socket => e
    reopen_connection
    retry
  rescue StandardError => e
    log_exception(e, params)
  end
end

def rest_put(path,params = nil, headers=nil)
  SystemDebug.debug(SystemDebug.registry,'Delete ', path.to_s + '?' + params.to_s)
  headers = {'Content-Type' =>'application/json', 'Accept' => '*/*'} if headers.nil?
  r = parse_xcon_response( connection.request(:read_timeout => time_out, :headers => headers,:method => :put,:path => @route_prefix + path,:query => query_hash(params).to_json ))
  #  connection.reset
  return r
rescue   Excon::Error::Socket => e
  reopen_connection
  retry
rescue StandardError => e
  log_exception(e, params)
  # end
end

def query_hash(params)

  unless params.nil?

    return params[:params] if params.key?(:params)
    return params
  end
  return nil
end

def rest_delete(path,params = nil, headers=nil)
  q = query_hash(params)
 # STDERR.puts('SEND ' +  path.to_s)
  #  STDERR.puts('SEND ' +  q.to_s)
  SystemDebug.debug(SystemDebug.registry,'DEL ', path.to_s + '?' + q.to_s)
  headers = {'Content-Type' =>'application/json', 'Accept' => '*/*'} if headers.nil?
  # q.to_json! unless q.nil? 
  r =  parse_xcon_response( connection.request(:read_timeout => time_out, :headers => headers,:method => :delete,:path => @route_prefix + path,:query => q))
  #  connection.reset
  return r
rescue   Excon::Error::Socket => e
  reopen_connection
  retry
  #  begin
  #    parse_rest_response(RestClient.delete(base_url + path, params))
  #    rescue RestClient::ExceptionWithResponse => e
  #      parse_error(e.response)
rescue StandardError => e
  log_exception(e, params)
  #end
end

private

def parse_error(resp)
  r = resp.body
  r.strip!# (/^\n/,'')
  # STDERR.puts("RSPONSE:" +r.to_s)

  # res = JSON.parse(r, :create_additions => true,:symbolize_keys => true)
  #STDERR.puts("RSPONSE:" + r.to_s)
  EnginesRegistryError.new(r)
rescue  StandardError => e
  STDERR.puts(e.to_s)
  STDERR.puts('Parse Error on error response object ', r.to_s)
  return EnginesRegistryError.new(resp)
  #log_error_mesg('Parse Error on error response object ', r.to_s)

end

def parse_xcon_response(resp)
  return STDERR.puts('nil resp')  if resp.nil?
  return false if resp.status  == 404
  return parse_error(resp) if resp.status > 399
  r = resp.body
  return false if r.nil?
  r.strip!
  return true if r.to_s   == '' ||  r.to_s   == 'true'
  return false if r.to_s  == 'false'
  hash = SystemUtils.deal_with_jason(JSON.parse(r, :create_additions => true))
  return hash
  rescue  StandardError => e
    STDERR.puts(e.to_s)
    STDERR.puts('Parse Error on error response object_' + r.to_s + '_')
  begin
    #  hash = json_parser.parse(r) # do |hash |
    hash =  SystemUtils.deal_with_jason(JSON.parse(r, :create_additons => true ))
      return hash
    #   end
  rescue  Yajl::ParseError  => e
    #   STDERR.puts e.backtrace
    STDERR.puts 'Yajl Failed to parse Registry response _' + r.to_s + '_'
    #  STDERR.puts e.class.name
    hash = SystemUtils.deal_with_jason(JSON.parse(r, :create_additions => true))
    STDERR.puts 'JSON parse as ' + hash.to_s + 'from' + r.to_s
      return hash
  end
  #return json_parser.parse(r, :create_additions => true,:symbolize_keys => true)
  # res = JSON.parse(r, :create_additions => true,:symbolize_keys => true)
  #return deal_with_jason(res)
rescue  StandardError => e
  STDERR.puts e.class.name

  STDERR.puts e.backtrace
  STDERR.puts 'Failed to parse Registry response _' + r.to_s + '_'
  return log_exception(e, r)
end


def base_url
  'http://' + @core_api.get_registry_ip + ':4567'
rescue  StandardError => e
  log_exception(e)
end

