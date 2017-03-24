

require 'rubygems'
require 'excon'

require 'yajl'

##used by events
#def get_json_stream(path)
#  require 'yajl'
#  chunk = ''
#
#  uri = URI(@base_url + path)
#  Net::HTTP.start(uri.host, uri.port)  do |http|
#    req = Net::HTTP::Get.new(uri)
#    req['access_token'] = ENV['access_token']
#    req['HTTP_access_token'] = ENV['access_token']
#    parser = Yajl::Parser.new(:symbolize_keys => true)
#    http.request(req) { |resp|
#      resp.read_body do |chunk|
#        begin
#          next if chunk == "\0" || chunk == "\n"
#          hash = parser.parse(chunk) do |hash|
#            p hash.to_json
#          end
#          #dont panic on bad json_parser as it is the \0 keep alive
#        rescue StandardError => e
#          p e
#          STDERR.puts('_'+ chunk + '_')
#          next
#        end
#      end
#
#    }
#    exit
#  end
#rescue StandardError => e
#  #Should goto to error hanlder but this is a script
#  p e.to_s
#  p e.backtrace.to_s
#end

## Used By builder command
#def get_stream(path, ostream=STDOUT)
#  #require 'yajl'
#  chunk = ''
#
#  uri = URI(@base_url + path)
#  req = Net::HTTP::Get.new(uri)
#  req['Access_Token'] = ENV['access_token']
#
#  Net::HTTP.start(uri.host, uri.port)  do |http|
#    http.read_timeout = 600
#    http.request(req) { |resp|
#      resp.read_body do |chunk|
#        #hash = parser.parse(chunk) do |hash|
#        ostream.write(chunk)
#        #end
#      end
#    }
#    exit
#  end
#rescue StandardError => e
#  p e.to_s
#  p chunk.to_s
#  p e.backtrace.to_s
#end



def connection(content_type = 'application/json_parser')
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
  STDERR.puts('Failed to open base url ' + @base_url.to_s)
end

def rest_del(uri,params=nil)

  if params.nil?
    connection.request(:method => :delete,:path => uri) #,:body => params.to_json)
  else
    connection.request(:method => :delete,:path => uri,:body => params.to_json)
  end
rescue StandardError => e

  STDERR.puts e.to_s + ' delete with path:' + uri + "\n" + 'params:' + params.to_s
  STDERR.puts e.backtrace.to_s
end

def rest_get(uri,params=nil,time_out=120)

  if params.nil?
    connection.request(:read_timeout => time_out,:method => :get,:path => uri) #,:body => params.to_json)
  else
    connection.request(:read_timeout => time_out,:method => :get,:path => uri,:body => params.to_json)
  end
rescue StandardError => e

  STDERR.puts e.to_s + ' with path:' + uri + "\n" + 'params:' + params.to_s
  STDERR.puts e.backtrace.to_s
end
def rest_post(uri, params, content_type,time_out = 120 )

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

def rest_delete(uri, params=nil)
  # params = add_access(params)
  begin
    if params.nil?
      r =  connection.request(:method => :delete,:path => uri) #,:body => params.to_json)
    else
      r =  connection.request(:method => :delete,:path => uri,:body => params.to_json)
    end
    write_response(r)
    exit

  rescue StandardError => e
    STDERR.puts e.to_s + ' with path:' + uri + "\n" + 'params:' + params.to_s
  end
end