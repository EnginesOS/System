require 'rubygems'
require 'excon'
require 'yajl'

#require_relative 'hijack.rb'
#Excon.defaults[:middlewares].unshift Excon::Middleware::Hijack

require_relative 'streamer.rb'

def connection(content_type = 'application/json_parser')
  @retries = 0
  headers = {
    'content_type' => content_type,
    'ACCESS_TOKEN' => load_token
  }
  headers.delete['ACCESS_TOKEN'] if headers['ACCESS_TOKEN'].nil?
  @connection = Excon.new(@base_url,
  debug_request: true,
  debug_response: true,
  ssl_verify_peer: false,
  persistent: true,
  headers: headers) if @connection.nil?
  @connection
rescue Excon::Error => e
  STDERR.puts('Failed to open base url ' + @base_url.to_s + ' ' + e.to_s + ' ' + e.class.name)
  if @retries < 5
    @retries += 1
    sleep 1
    retry
  end
  STDERR.puts('Failed to open base url ' + @base_url.to_s + ' after ' + @retries.to_s = ' attempts')
rescue StandardError =>e
  STDERR.puts('Uncatch E ' + e.class.name + ' ' + e.to_s)
end

class Chunked
  def initialize(data, chunk_size)
    @size = chunk_size
    if data.respond_to? :read
      @file = data
    end
  end
  
  def read(foo, bar)
    STDERR.puts('FOO:' + foo.to_s + ' Bar:' + bar.to_s)
    if @file
      @file.read(foo)
    end
  end
  def eof!
    @file.eof!
  end
  def eof?
    @file.eof?
  end
end
def mstream_io(uri_s, io_h)
chunked = Chunked.new(io_h, Excon.defaults[:chunk_size])
  headers = {
    'Content-Type' => 'application/octet-stream',
    'ACCESS_TOKEN' => load_token,   
  #  'Transfer-Encoding' => 'chunked',
  }
#request = Net::HTTP::Put.new parsed.request_uri, {'x-auth-token' => @auth_token, 'Transfer-Encoding' => 'chunked', 'content-type' => 'text/plain'}
  uri = URI(@base_url + uri_s)
    # STDERR.puts('uri ' + uri.to_s)
    conn = Net::HTTP.new(uri.host, uri.port)
    conn.use_ssl = true
    conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
    # if  post == true
    #  request = Net::HTTP::Post.new(uri.request_uri, headers)
    #  else
    request = Net::HTTP::Post.new(uri.request_uri, headers)
    # STDERR.puts('request ' + request.to_s)
    #  end
      request.body_stream = src_f
      r = conn.request(request)
      write_response(r)
#request.body_stream = chunked
#conn.start do |http| 
 # http.request(request)
#end
exit
end
def stream_io(uri_s, io_h)

  chunker = lambda do
    # Excon.defaults[:chunk_size] defaults to 1048576, ie 1MB
    # to_s will convert the nil received after everything is read to the final empty chunk
    STDERR.puts('Get Chunk')
    c = io_h.read(Excon.defaults[:chunk_size]).to_s
     STDERR.puts('Got Chunk ' + c.length.to_s)
    c
  end
  uri = URI(@base_url + uri_s)
  headers = {
    'Content-Type' => 'application/octet-stream',
    'ACCESS_TOKEN' => load_token,   
    'Transfer-Encoding' => 'chunked',
  }

  r = Excon.post(@base_url + uri_s, :request_block => chunker, headers: headers,
  debug_request: true,
  debug_response: true,
  ssl_verify_peer: false,
  persistent: true)
  STDERR.puts('r')
  io_h.close
  STDERR.puts('r')
  #stream_file(uri_s, io_h, headers)
  exit
end

def stream_file(uri_s, src_f, headers = nil)
  headers = {
    'Content-Type' => 'application/octet-stream',
    'Accept-Encoding' => 'gzip',
    'ACCESS_TOKEN' => load_token,
     #'Transfer-Encoding' => 'chunked',
    'Content-Length' => src_f.size.to_s
  } if headers.nil?
  # STDERR.puts('stream header ' + headers.to_s)
  uri = URI(@base_url + uri_s)
  # STDERR.puts('uri ' + uri.to_s)
  conn = Net::HTTP.new(uri.host, uri.port)
  conn.use_ssl = true
  conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
  # if  post == true
  #  request = Net::HTTP::Post.new(uri.request_uri, headers)
  #  else
  request = Net::HTTP::Post.new(uri.request_uri, headers)
  # STDERR.puts('request ' + request.to_s)
  #  end
  request.body_stream = src_f
  r = conn.request(request)
  #   conn.start do |http|
  #  r = http.request(request)
  #STDERR.puts('STREAM RESULT ' + r.inspect + ':' + r.body.to_s)
  #   end
  write_response(r)
  exit
rescue StandardError => e
  STDERR.puts('socket stream closed ' + e.to_s + e.backtrace.to_s)
end

#def stream_connection(uri_s, stream_reader)
#  headers = {
#     'content_type' => 'application/octet-stream',
#     'ACCESS_TOKEN' => load_token,
#     'Transfer-Encoding' => 'chunked'
#  }
#  uri = URI(@base_url + uri_s)
#  STDERR.puts('uri ' + uri.to_s)
#  conn = Net::HTTP.new(uri.host, uri.port)
#  conn.use_ssl = true
#  conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
#  request = Net::HTTP::Put.new(uri.request_uri, headers)
#  STDERR.puts request.inspect
#  request.body_stream = stream_reader
#  conn.request(request)
#  rescue StandardError => e
#  STDERR.puts('socket stream closed ' + e.to_s + e.backtrace.to_s)
#  end
#
def rest_stream_put(uri, data_io)
  #stream_handler = Streamer.new(data_io)
  #r = stream_connection(uri, stream_handler)
  r =  stream_file(uri, data_io)
  #    stream_handler.stream = sc
  #  r = sc.request(
  #  method: :put,
  # read_timeout: 3600,
  # path: uri,
  # body: nil
  #  )
  #  stream_handler.close
  #  stream_handler.close
  write_response(r)

rescue StandardError => e
  STDERR.puts('socket stream closed ' + e.to_s + e.backtrace.to_s)
  #stream_handler.close
end

def rest_del(uri, params=nil, time_out=23)
  @retries = 0
  if params.nil?
    connection.request(read_timeout: time_out, method: :delete, path: uri)
  else
    connection.request(read_timeout: time_out, method: :delete, path: uri, body: params.to_json)
  end
rescue Excon::Error::Socket
  if @retries < 2
    @retries +=1
    sleep 1
    retry
  end
  STDERR.puts('Failed to url ' + uri.to_s + ' after ' + @retries.to_s = ' attempts')
rescue StandardError => e
  STDERR.puts e.to_s + ' delete with path:' + uri + "\n" + 'params:' + params.to_s
  STDERR.puts e.backtrace.to_s
end

def rest_get(uri, time_out = 135, params = nil)

  time_out = @wait_for unless @wait_for.nil?
  @retries = 0
  #  STDERR.puts('Waiting for ' + time_out.to_s)
  if params.nil?
    connection.request({read_timeout: time_out, method: :get, path: uri})
  else
    # STDERR.puts('Got Params ' +params.to_s)
    connection.request({read_timeout: time_out, method: :get, path: uri, query: params})
  end
rescue Excon::Error::Socket => e
  STDERR.puts e.to_s + ' with path:' + uri + "\n" + 'params:' + params.to_s + ' R ' + @retries.to_s
  if @retries < 5
    @retries +=1
    sleep 1
    retry
  end
  STDERR.puts('Failed to url ' + uri.to_s + ' after ' + @retries.to_s + ' attempts')
rescue StandardError => e
  STDERR.puts e.to_s + ' with path:' + uri + "\n" + 'params:' + params.to_s
  STDERR.puts e.class.name
  STDERR.puts e.backtrace.to_s
end

def rest_post(uri, params, content_type, time_out = 44 )
  @retries = 0
  begin
    unless params.nil?
      r = connection(content_type).request(read_timeout: time_out,
      method: :post,
      path: uri,
      body: params.to_json) #,:body => params.to_json)
    else
      r = connection(content_type).request(read_timeout: time_out,
      method: :post,
      path: uri)
    end
    write_response(r)
    exit
  rescue Excon::Error::Socket
    #    if @retries < 10
    #      @retries +=1
    #      sleep 1
    #      retry
    #    end
    STDERR.puts('Failed to url ' + uri.to_s )
  rescue StandardError => e
    STDERR.puts e.to_s + ' with path:' + uri + "\n" + 'params:' + params.to_s
    STDERR.puts e.backtrace.to_s
    params[:api_vars][:data] = nil
    STDERR.puts e.to_s + ' with path:' + uri + "\n" + 'params:' + params.to_s
    STDERR.puts r.to_s
  end
end

def rest_put(uri, params, content_type, time_out = 44 )
  @retries = 0
  begin
    unless params.nil?
      params = params.to_json if content_type == 'application/json_parser'
      r = connection(content_type).request(read_timeout: time_out,
      method: :put,
      path: uri,
      body: params)
    else
      r = connection(content_type).request(read_timeout: time_out,
      method: :put,
      path: uri)
    end
    write_response(r)
    exit
  rescue Excon::Error::Socket => e
    #    if @retries < 10
    #      @retries +=1
    #      sleep 1
    #      retry
    #    end
    STDERR.puts('Failed to puy url ' + uri.to_s + e.to_s)
  rescue StandardError => e
    STDERR.puts e.to_s + ' with path:' + uri + "\n" + 'params:' + params.to_s
    STDERR.puts e.backtrace.to_s
    params[:api_vars][:data] = nil
    STDERR.puts e.to_s + ' with path:' + uri + "\n" + 'params:' + params.to_s
    STDERR.puts r.to_s
  end
end

def rest_delete(uri, params=nil, time_out = 20)
  @retries = 0
  # params = add_access(params)
  begin
    if params.nil?
      r = connection.request(read_timeout: time_out, method: :delete, path: uri) #,:body => params.to_json)
    else
      r = connection.request(read_timeout: time_out, method: :delete, path: uri, body: params.to_json)
    end
    write_response(r)
    exit
  rescue Excon::Error::Socket
    if @retries < 2
      @retries +=1
      sleep 1
      retry
    end
    STDERR.puts('Failed to url ' + uri.to_s + ' after ' + @retries.to_s = ' attempts')
  rescue StandardError => e
    STDERR.puts e.to_s + ' with path:' + uri + "\n" + 'params:' + params.to_s
  end
end