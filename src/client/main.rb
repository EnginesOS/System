if Process.euid != 21000
  STDERR.puts("This program can only be run be the engines user")
  exit
end
require 'rubygems'
require 'json'
require 'yajl'

require_relative 'client_http_requests.rb'
require_relative 'client_login.rb'
require_relative 'client_http_stream.rb'
include ClientHTTPStream

@silent = true

def log_error(*args)
  STDERR.puts(args.to_s) unless @silent == true
end

def command_usage(mesg=nil)
  p "Incorrect usage"
  p mesg
  p get_help_info
  exit
end

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

  if resp.status  >= 400
    log_error("Error " + resp.status.to_s)
    return 'fail' if resp.body.nil?
  end

  return 'OK' if resp.status  == 204   # nodata but all good happens on del

  unless resp.status  >= 200
    log_error("Un exepect response from system" + resp.status.to_s + ' ' + resp.body.to_s + ' ' + resp.headers.to_s)
  end

  return resp.body.to_s unless expect_json == true
  hashes = []
  parser.parse(resp.body) do |hash |
    hashes.push(hash)
  end
  return hashes[0].to_json
rescue StandardError => e
  log_error(e.to_s + ' with :' + resp.to_s)
  log_error(e.backtrace.to_s)
end

def write_response(r)
  if r.nil?
    log_error('nil response')
    return
  end
  if r.headers['Content-Type'] == 'application/octet-stream'
    STDOUT.write( r.body.b)
  else
    expect_json = false
    expect_json = true if r.headers['Content-Type'] == 'application/json' || r.body.start_with?('{')
    puts handle_resp(r, expect_json)
  end

end

require_relative 'cmdline_args.rb'

cmdline_options = process_args
command_usage(cmdline_options) if cmdline_options.is_a?(String)



if cmdline_options.key?(:base_url)
  @base_url= cmdline_options[:base_url]
else
  @host = cmdline_options[:host] if cmdline_options.key?(:host)
  @port = cmdline_options[:port] if cmdline_options.key?(:port)
  @route = cmdline_options[:prefix] if cmdline_options.key?(:prefix)
end
puts 'set Base url  ' + @base_url.to_s
require_relative 'default_connection_settings.rb'
puts 'using Base url  ' + @base_url.to_s
@silent = false if cmdline_options.key?(:verbose)

#ENV['access_token'] = cmdline_options[:access_token] if cmdline_options.key?(:access_token)
#load_token if ENV['access_token'].nil?
#login if ENV['access_token'].nil?

require_relative 'commands/commands.rb'

