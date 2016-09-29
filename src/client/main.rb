if Process.euid != 21000
  STDERR.puts("This program can only be run be the engines user")
  exit
end
require 'rubygems'
require 'yajl'

require_relative 'client_http_requests.rb'
require_relative 'client_login.rb'
require_relative 'client_http_stream.rb'
include ClientHTTPStream

def command_useage(mesg=nil)
  p "Incorrect usage"
  p mesg
  exit
end

#def parse_rest_response(r)
#  return false if r.code > 399
#  return true if r.to_s   == '' ||  r.to_s   == 'true'
#  return false if r.to_s  == 'false'
#  return r.to_s if @raw
#  parser = Yajl::Parser.new()
#  res = parser.parse(r)
#  return res
#rescue  StandardError => e
#  STDERR.puts e.to_s
#  STDERR.puts e.backtrace
#  STDERR.puts "Failed to parse system response _" + r.to_s + "_"
#  return false
#end

def read_stdin_data
  stdin_data = ""
  require 'timeout'
  status = Timeout::timeout(30) do
    while STDIN.gets
      stdin_data += $_
    end
  end
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
  r = rest_get(@route)
  write_response(r)
  exit
end

def perform_del
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
  rest_delete(@route,params)
  exit
end

def handle_resp(resp, expect_json=true)
  parser = Yajl::Parser.new()
  STDERR.puts("Error " + resp.status.to_s)  if resp.status  >= 400
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

