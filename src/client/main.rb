if Process.euid != 21000
  STDERR.puts("This program can only be run be the engines user")
  exit
end
require 'rubygems'
require 'excon'
require 'json'
require 'yajl'

def command_useage(mesg=nil)
  p "Incorrect usage"
  p mesg
  exit
end

def parse_rest_response(r)
  return false if r.code > 399
  return true if r.to_s   == '' ||  r.to_s   == 'true'
  return false if r.to_s  == 'false'
  return r.to_s if @raw
  parser = Yajl::Parser.new()
  res = parser.parse(r)
  # res = JSON.parse(r, :create_additions => true,:symbolize_keys => true)
  # STDERR.puts("RESPONSE "  + deal_with_jason(res).to_s)
  return deal_with_jason(res)
rescue  StandardError => e
  STDERR.puts e.to_s
  STDERR.puts e.backtrace
  STDERR.puts "Failed to parse system response _" + r.to_s + "_"
  return false
end

#def base_url
#  'http://' + @core_api.get_registry_ip + ':4567'
#rescue  StandardError => e
#  STDERR.puts e.to_s
#end

def read_stdin_data
  stdin_data = ""

  require 'timeout'
  status = Timeout::timeout(30) do
    while STDIN.gets
      stdin_data += $_
    end
  end
  #STDERR.puts "Read " + stdin_data.length.to_s + ' bytes'
  stdin_data
rescue Timeout::Error
  puts "Timeout on data read from stdin"
rescue StandardError => e
  log_exception(e)
end

def read_stdin_json
  JSON.parse(read_stdin_data)
end

def perform_get
  #STDERR.puts  @route
  r = rest_get(@route)
  write_response(r)
  exit
end

def perform_del
  #STDERR.puts  @route
  r = rest_del(@route)
  write_response(r)
  exit
end

def perform_post(params, content_type='application/json')
  post_params = {}
  post_params[:api_vars] = params
  rest_post(@route,post_params, content_type)
  exit
end

def perform_delete(params=nil)
  #STDERR.puts  @route
  rest_delete(@route,params)
  exit
end

require 'rest-client'

#used by events
def get_json_stream(path)
  require 'yajl'
  chunk = ''

  uri = URI(@base_url + path)
  Net::HTTP.start(uri.host, uri.port)  do |http|
    req = Net::HTTP::Get.new(uri)
    req['access_token'] = ENV['access_token']
    req['HTTP_access_token'] = ENV['access_token']
    parser = Yajl::Parser.new(:symbolize_keys => true)
    http.request(req) { |resp|
      resp.read_body do |chunk|
        begin
          next if chunk == "\0" || chunk == "\n"
          hash = parser.parse(chunk) do |hash|
            p hash.to_json
          end
          #dont panic on bad json as it is the \0 keep alive
        rescue StandardError => e
          p e
          STDERR.puts('_'+ chunk + '_')
          next
        end
      end

    }
    exit
  end
rescue StandardError => e
  #Should goto to error hanlder but this is a script
  p e.to_s
  p e.backtrace.to_s
end

## Used By builder command
def get_stream(path, ostream=STDOUT)
  #require 'yajl'
  chunk = ''

  uri = URI(@base_url + path)
  req = Net::HTTP::Get.new(uri)
  req['Access_Token'] = ENV['access_token']

  Net::HTTP.start(uri.host, uri.port)  do |http|
    http.read_timeout = 600
    http.request(req) { |resp|
      resp.read_body do |chunk|
        #hash = parser.parse(chunk) do |hash|
        ostream.write(chunk)
        #end
      end
    }
    exit
  end
rescue StandardError => e
  p e.to_s
  p chunk.to_s
  p e.backtrace.to_s
end

def path_with_params(path, params)
  encoded_params = URI.encode_www_form(params)
  [path, encoded_params].join("?")
end

def add_access(params)
  params = {} if params.nil?
  params['access_token'] = ENV['access_token']
  params
end

def connection(content_type = 'application/json')
  headers = {}
  headers['content_type'] = content_type
  headers['ACCESS_TOKEN'] = load_token
  @connection = Excon.new(@base_url,
  :debug_request => true,
  :debug_response => true,
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

def handle_resp(resp, expect_json=true)
  parser = Yajl::Parser.new()

  #STDERR.puts(" RESPOSE " + resp.to_s)
  # STDERR.puts(" RESPOSE " + resp.status.to_s + " : " + resp.body  )
  STDERR.puts("error:" + resp.status.to_s)  if resp.status  >= 400
  return 'OK' if resp.status  == 204   # nodata but all good happens on del
  STDERR.puts "Un exepect response from system" + resp.status.to_s + ' ' + resp.body.to_s + ' ' + resp.headers.to_s    unless resp.status  == 200 ||  resp.status  == 201 || resp.status  == 202
  return resp.body.to_s unless expect_json == true
  hashes = []
  parser.parse(resp.body) do |hash |
    hashes.push(hash)
  end
  return hashes[0].to_json
rescue StandardError => e
  STDERR.puts e.to_s + ' with :' + resp.to_s
  STDERR.puts e.backtrace.to_s
end

#def rest_get(path,params=nil)
#
#  begin
#    retry_count = 0
#    # STDERR.puts('Get Path:' + path.to_s + ' Params:' + params.to_s)
#    params = add_access(params)
#    r = RestClient.get(@base_url + path, params) #, { :access_token => load_token})
#
#    return r
#  rescue RestClient::ExceptionWithResponse => e
#    parse_error(e.response)
#  rescue StandardError => e
#
#    STDERR.puts e.to_s + ' with path:' + path + "\n" + 'params:' + params.to_s
#    STDERR.puts e.backtrace.to_s
#  end
#end

def write_response(r)
  if r.nil?
    STDERR.puts 'nil response'
    return
  end
  #STDERR.puts( 'RESPONSE HEADER ' + r.headers.to_s)
  if r.headers['Content-Type'] == 'application/octet-stream'
    STDOUT.write( r.body.b)
    # STDERR.puts "as_binary"
  else
    expect_json=false
    expect_json=true if r.body.start_with?('{')
    puts handle_resp(r, expect_json)
  end

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

def login
  r = rest_get('/v0/system/login/test/test')
  ENV['access_token'] = r.body.gsub!(/\"/,'')
  t = File.new(Dir.home + '/.engines_token','w+')
  t.write(ENV['access_token'])
  t.close
end

def load_token
  return false unless File.exist?(Dir.home + '/.engines_token')
  ENV['access_token'] = File.read(Dir.home + '/.engines_token')
  ENV['access_token'] = ENV['access_token'].strip
  ENV['access_token']
end

def  process_args

end

@host = ENV['DOCKER_IP']
@host = '127.0.0.1' if @host.length < 3
@base_url = 'http://' +  @host + ':2380'
@port = '2380'
@route = "/v0"

load_token
login if ENV['access_token'].nil?

process_args

require_relative 'commands/commands.rb'

#require_relative 'rset.rb'

