require 'rubygems'
require 'excon'
require 'yajl'

def connection( content_type = 'application/json_parser')
  retries = 0
  headers = {}
  headers['content_type'] = content_type
  headers['ACCESS_TOKEN'] = load_token
  headers.delete['ACCESS_TOKEN'] if headers['ACCESS_TOKEN'].nil?
  @connection = Excon.new(@base_url,
  :debug_request => true,
  :debug_response => true,
  :ssl_verify_peer => false,
  :persistent => true,
  :headers => headers) if @connection.nil?
  @connection
rescue StandardError => e
  if retries < 10
    retries +=1
    sleep 1
    retry
  end
  STDERR.puts('Failed to open base url ' + @base_url.to_s + ' after ' + retries.to_s = ' attempts')
end

def rest_del(uri, params=nil, time_out=23)
  if params.nil?
    connection.request(:read_timeout => time_out,:method => :delete,:path => uri)
  else
    connection.request(:read_timeout => time_out,:method => :delete,:path => uri, :body => params.to_json)
  end
rescue StandardError => e
  STDERR.puts e.to_s + ' delete with path:' + uri + "\n" + 'params:' + params.to_s
  STDERR.puts e.backtrace.to_s
end

def rest_get(uri, time_out = 35, params = nil)
  retries = 0
  if params.nil?
    connection.request({:read_timeout => time_out, :method => :get, :path => uri})
  else
    connection.request({:read_timeout => time_out, :method => :get, :path => uri, :body => params.to_json})
  end
rescue Errno::ECONNREFUSED
  if retries < 10
    retries +=1
    sleep 1
    retry    
  end
  STDERR.puts('Failed to open base url ' + uri.to_s + ' after ' + retries.to_s = ' attempts')
rescue StandardError => e
  STDERR.puts e.to_s + ' with path:' + uri + "\n" + 'params:' + params.to_s
  STDERR.puts e.backtrace.to_s
end

def rest_post(uri, params, content_type,time_out = 44 )
  begin
    unless params.nil?
      r =  connection(content_type).request(:read_timeout => time_out,:method => :post,:path => uri, :body => params.to_json) #,:body => params.to_json)
    else
      r =  connection(content_type).request(:read_timeout => time_out,:method => :post,:path => uri)
    end
    write_response(r)
    exit
  rescue StandardError => e
    STDERR.puts e.to_s + ' with path:' + uri + "\n" + 'params:' + params.to_s
    STDERR.puts e.backtrace.to_s
    params[:api_vars][:data] = nil
    STDERR.puts e.to_s + ' with path:' + uri + "\n" + 'params:' + params.to_s
    STDERR.puts r.to_s
  end
end

def rest_delete(uri, params=nil, time_out = 20)
  # params = add_access(params)
  begin
    if params.nil?
      r = connection.request(:read_timeout => time_out,:method => :delete,:path => uri) #,:body => params.to_json)
    else
      r = connection.request(:read_timeout => time_out,:method => :delete,:path => uri,:body => params.to_json)
    end
    write_response(r)
    exit
  rescue StandardError => e
    STDERR.puts e.to_s + ' with path:' + uri + "\n" + 'params:' + params.to_s
  end
end