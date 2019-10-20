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
@verbose = false

def log_error(*args)
  unless @silent == true

    if @verbose == true
      STDERR.puts(args.to_s)
    else
      STDERR.puts(args.to_s[0..64])
    end
  end
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

def perform_get(time_out = 34, params = {} )
  r = rest_get(@route, time_out ,params)
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

def stream_put(data_io)
  rest_stream_put(@route, data_io)
  exit
end

def perform_put(params, content_type = 'application/json')
  unless params == nil
    post_params = {api_vars: params}
  else
    post_params = nil
  end
  #STDERR.puts('Posting ' + post_params.to_s)
  rest_put(@route, post_params, content_type)
  exit
end

def perform_delete(params = nil)
  rest_delete(@route, params)
  exit
end

def json_parser
  @json_parser ||= FFI_Yajl::Parser.new(symbolize_keys: true)
end

def handle_resp(resp, expect_json = true)
  r = nil
  #  STDERR.puts('GOT JSON' + resp.body)
  if resp.status >= 400
    log_error("Error " + resp.status.to_s)
    if resp.body.nil?
      r = 'fail'
    end
  elsif resp.status == 204   # nodata but all good happens on del
    r = 'true'
  elsif resp.status >= 200 && resp.status < 300
    resp.body
  else
    log_error("Un exepect response from system" + resp.status.to_s + ' ' + resp.body.to_s + ' ' + resp.to_s)
  end

  # STDERR.puts('GOT body ' + resp.body + "\nas JSON:" +  expect_json.to_s)
  if expect_json == true && r.nil?
     # STDERR.puts('GOT JSON' + resp.body)
    resp.body
   #o = json_parser.parse(resp.body)
    #o = JSON.parse(resp.body)
    # STDERR.puts('O IS' + o.class.name)
    #o.to_s
  else
    if r.nil?
      resp.body
    else
      r
    end
  end
rescue StandardError => e
  log_error(e.to_s + ' with :' + resp.to_s)
  log_error(e.backtrace.to_s)
end

def write_response(r)
  # STDERR.puts('Response Class for name ' + r.class.name)
  if r.nil?
    log_error('nil response')
  elsif r.headers['Content-Type'] == 'application/octet-stream'
    STDOUT.write(r.body.b) unless r.body.nil?
  else
    expect_json = false
    expect_json = true if r.headers['Content-Type'] == 'application/json' || r.body.start_with?('{')
    puts handle_resp(r, expect_json)
  end
rescue StandardError => e
  log_error(e.to_s + ' with :' + r.to_s)
  log_error(e.backtrace.to_s) if @verbose == true
end

require_relative 'cmdline_args.rb'

@options = process_args
command_usage(@options) unless @options.is_a?(Hash)

if @options.key?(:base_url)
  @base_url= @options[:base_url]
else
  @host = @options[:host] if @options.key?(:host)
  @port = @options[:port] if @options.key?(:port)
  @route = @options[:prefix] if @options.key?(:prefix)
  @use_https = @options[:use_https] if @options.key?(:use_https)
end

require_relative 'default_connection_settings.rb'

@silent = @options[:silent]
@verbose = @options[:verbose]

ENV['access_token'] = @options[:access_token] if @options.key?(:access_token)
load_token if ENV['access_token'].nil?

require_relative 'commands/commands.rb'

