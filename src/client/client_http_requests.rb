require 'rubygems'
require 'excon'
require 'yajl'
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



def stream_connection(stream_reader)
    excon_params = {
      debug_request: true,
      debug_response: true,
      persistent: false,
      response_block: stream_reader.process_response,
      ssl_verify_peer: false,
      headers: { 'Content-Type' => 'application/tar',
        'ACCESS_TOKEN' => load_token
      }
    }
    Excon.new(@base_url, excon_params)
  end
  
def rest_stream_put(uri, data_io)
  stream_handler = Streamer.new(data_io)
  sc = stream_connection(stream_handler)
    stream_handler.stream = sc
  r = sc.request(
  method: :put,
  read_timeout: 3600,
  path: uri,
  body: nil
  )
  stream_handler.close


rescue Excon::Error::Socket
STDERR.puts('socket stream closed')
stream_handler.close
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

def rest_get(uri, time_out = 35, params = nil)

  @retries = 0
  if params.nil?
    connection.request({read_timeout: time_out, method: :get, path: uri})
  else
    connection.request({read_timeout: time_out, method: :get, path: uri, body: params.to_json})
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