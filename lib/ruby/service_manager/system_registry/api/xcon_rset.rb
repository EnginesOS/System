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
   #headers['content_type'] = content_type unless content.nil?
  #headers['ACCESS_TOKEN'] = load_token
  #  @connection.reset unless @connection.nil?

  #  if @connection.nil?
 #   STDERR.puts('NEW REGISTRY CONNECTION ')
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

#def rest_get(path,params)
#  return base_url if base_url.is_a?(EnginesError)
#  begin
#    retry_count = 0
#   STDERR.puts('Get Path:' + path.to_s + ' Params:' + params.to_s + ' base_url ' + base_url.to_s)
#
#    parse_rest_response(RestClient.get(base_url + path, params))
#   rescue RestClient::ExceptionWithResponse => e
#     parse_error(e.response)
#  rescue StandardError => e
#    log_exception(e, params)
#
#  end
#end

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
 # STDERR.puts(' PUT ' + path.to_s )
  #  STDERR.puts('PUT params ' + query_hash(params).to_s )
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
  STDERR.puts("Parse Error on error response object ", r.to_s)
  return EnginesRegistryError.new(resp)
  #log_error_mesg("Parse Error on error response object ", r.to_s)

end

def parse_xcon_response(resp)
  return {} if resp.status  == 404

  return parse_error(resp) if resp.status > 399
  r = resp.body
  r.strip!
  return true if r.to_s   == '' ||  r.to_s   == 'true'
  return false if r.to_s  == 'false'
  hash = SystemUtils.deal_with_jason(JSON.parse(r, :create_additions => true))
  return hash
  rescue  StandardError => e
    STDERR.puts(e.to_s)
    STDERR.puts("Parse Error on error response object_" + r.to_s + '_')
  begin
    #  hash = json_parser.parse(r) # do |hash |
    hash =  SystemUtils.deal_with_jason(JSON.parse(r, :create_additons => true ))
      return hash
    #   end
  rescue  Yajl::ParseError  => e
    #   STDERR.puts e.backtrace
    STDERR.puts "Yajl Failed to parse Registry response _" + r.to_s + "_"
    #  STDERR.puts e.class.name
    hash = SystemUtils.deal_with_jason(JSON.parse(r, :create_additions => true))
    STDERR.puts "JSON parse as " + hash.to_s + 'from' + r.to_s
      return hash
  end
  #return json_parser.parse(r, :create_additions => true,:symbolize_keys => true)
  # res = JSON.parse(r, :create_additions => true,:symbolize_keys => true)
  #return deal_with_jason(res)
rescue  StandardError => e
  STDERR.puts e.class.name

  STDERR.puts e.backtrace
  STDERR.puts "Failed to parse Registry response _" + r.to_s + "_"
  return log_exception(e, r)
end

#def parse_rest_response(r)
#  return parse_error(r) if r.code > 399
#  return true if r.to_s   == '' ||  r.to_s   == 'true'
#  return false if r.to_s  == 'false'
#  r.strip!
#  res = JSON.parse(r, :create_additions => true,:symbolize_keys => true)
#  return deal_with_jason(res)
#rescue  StandardError => e
#  STDERR.puts e.to_s
#  STDERR.puts e.backtrace
#  STDERR.puts "Failed to parse Registry response _" + r.to_s + "_"
#  return log_exception(e, r)
#end

#def deal_with_jason(res)
#  return symbolize_keys(res) if res.is_a?(Hash)
#  return symbolize_keys_array_members(res) if res.is_a?(Array)
#  return symbolize_tree(res) if res.is_a?(Tree::TreeNode)
#  return boolean_if_true_false_str(res) if res.is_a?(String)
#  return res
#rescue  StandardError => e
#  log_exception(e, res)
#end
#
#def boolean_if_true_false_str(r)
#  if  r == 'true'
#    return true
#  elsif r == 'false'
#    return false
#  end
#  return r
#rescue  StandardError => e
#  log_exception(e, r)
#end
#
#def symbolize_keys(hash)
#  hash.inject({}){|result, (key, value)|
#    new_key = case key
#    when String then key.to_sym
#    else key
#    end
#    new_value = case value
#    when Hash then symbolize_keys(value)
#    when Array then
#      newval = []
#      value.each do |array_val|
#        array_val = symbolize_keys(array_val) if array_val.is_a?(Hash)
#        array_val =  boolean_if_true_false_str(array_val) if array_val.is_a?(String)
#        newval.push(array_val)
#      end
#      newval
#    when String then
#      boolean_if_true_false_str(value)
#    else value
#    end
#    result[new_key] = new_value
#    result
#  }
#rescue  StandardError => e
#  log_exception(e, hash)
#end
#
#def symbolize_keys_array_members(array)
#  return array if array.count == 0
#  return array unless array[0].is_a?(Hash)
#  retval = []
#  i = 0
#  array.each do |hash|
#    retval[i] = array[i]
#    next if hash.nil?
#    next unless hash.is_a?(Hash)
#    retval[i] = symbolize_keys(hash)
#    i += 1
#  end
#  return retval
#
#rescue  StandardError => e
#  log_exception(e)
#end
#
#def symbolize_tree(tree)
#  nodes = tree.children
#  nodes.each do |node|
#    node.content = symbolize_keys(node.content) if node.content.is_a?(Hash)
#    symbolize_tree(node)
#  end
#  return tree
#rescue  StandardError => e
#  log_exception(e)
#end

def base_url
  'http://' + @core_api.get_registry_ip + ':4567'
rescue  StandardError => e
  log_exception(e)
end

