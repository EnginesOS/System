if Process.euid != 21000
  STDERR.puts("This program can only be run be the engines user")
  exit
end
require 'rubygems'
require 'json'
require 'yajl'
require 'ffi_yajl'

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
  status = Timeout::timeout(63) do
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
  json_parser.parse(read_stdin_data)
end

def perform_get(time_out = 34)
  r = rest_get(@route, time_out)
  write_response(r)
  exit
end

def perform_del(time_out = 35)
  r = rest_del(@route, time_out)
  write_response(r)
  exit
end

def perform_post(params, content_type='application/json')
  post_params = {api_vars: params}
  rest_post(@route,post_params, content_type)
  exit
end

def perform_delete(params=nil)
  rest_delete(@route,params)
  exit
end

def json_parser
  @json_parser ||= FFI_Yajl::Parser.new(symbolize_keys: true)
end

def handle_resp(resp, expect_json = true)
  
  if resp.status >= 400
    log_error("Error " + resp.status.to_s)
    if resp.body.nil?
      r = 'fail'
    else
      r =  resp.body
    end
  elsif resp.status == 204   # nodata but all good happens on del
    r =  'OK'
  elsif resp.status >= 200 && resp.status < 300
    r = resp.body
  else
    log_error("Un exepect response from system" + resp.status.to_s + ' ' + resp.body.to_s + ' ' + resp.headers.to_s)
  end
  if expect_json == true
    JSON.parse(resp.body).to_s
  end
rescue StandardError => e
  log_error(e.to_s + ' with :' + resp.to_s)
  log_error(e.backtrace.to_s)
end

def write_response(r)
  if r.nil?
    log_error('nil response')
  elsif r.headers['Content-Type'] == 'application/octet-stream'
    STDOUT.write(r.body.b)
  else
    expect_json = false
    expect_json = true if r.headers['Content-Type'] == 'application/json_parser' || r.body.start_with?('{')
    puts handle_resp(r, expect_json)     
  end
rescue StandardError => e
  log_error(e.to_s + ' with :' + resp.to_s)
  log_error(e.backtrace.to_s)
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
  @use_https = cmdline_options[:use_https] if cmdline_options.key?(:use_https)
end

require_relative 'default_connection_settings.rb'

@silent = false if cmdline_options.key?(:verbose)

ENV['access_token'] = cmdline_options[:access_token] if cmdline_options.key?(:access_token)
load_token if ENV['access_token'].nil?
#login if ENV['access_token'].nil?

require_relative 'commands/commands.rb'

