
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

def parse_error(r)
  STDOUT.puts r.to_s
  exit (-1)

end

def parse_rest_response(r)
  return false if r.code > 399
  return true if r.to_s   == '' ||  r.to_s   == 'true'
  return false if r.to_s  == 'false'
  return r.to_s if @raw
  parser = Yajl::Parser.new(:symbolize_keys => true)
  res = parser.parse(r)
 # res = JSON.parse(r, :create_additions => true,:symbolize_keys => true)
  # STDERR.puts("RESPONSE "  + deal_with_jason(res).to_s)
  return deal_with_jason(res)
rescue  StandardError => e
  STDERR.puts e.to_s
  STDERR.puts e.backtrace
  STDERR.puts "Failed to parse rest response _" + r.to_s + "_"
  return false
end

def deal_with_jason(res)
  return res
  return symbolize_keys(res) if res.is_a?(Hash)
  return symbolize_keys_array_members(res) if res.is_a?(Array)
  return symbolize_tree(res) if res.is_a?(Tree::TreeNode)
  return boolean_if_true_false_str(res) if res.is_a?(String)
  return res
rescue  StandardError => e
  STDERR.puts e.to_s
end

def boolean_if_true_false_str(r)
  if  r == 'true'
    return true
  elsif r == 'false'
    return false
  end
  return r
rescue  StandardError => e
  STDERR.puts e.to_s
end

def symbolize_keys(hash)
  hash.inject({}){|result, (key, value)|
    new_key = case key
    when String then key.to_sym
    else key
    end
    new_value = case value
    when Hash then symbolize_keys(value)
    when Array then
      newval = []
      value.each do |array_val|
        array_val = symbolize_keys(array_val) if array_val.is_a?(Hash)
        array_val =  boolean_if_true_false_str(array_val) if array_val.is_a?(String)
        newval.push(array_val)
      end
      newval
    when String then
      boolean_if_true_false_str(value)
    else value
    end
    result[new_key] = new_value
    result
  }
rescue  StandardError => e
  STDERR.puts e.to_s
end

def symbolize_keys_array_members(array)
  return array if array.count == 0
  return array unless array[0].is_a?(Hash)
  retval = []
  i = 0
  array.each do |hash|
    retval[i] = array[i]
    next if hash.nil?
    next unless hash.is_a?(Hash)
    retval[i] = symbolize_keys(hash)
    i += 1
  end
  return retval

rescue  StandardError => e
  STDERR.puts e.to_s
end

def symbolize_tree(tree)
  nodes = tree.children
  nodes.each do |node|
    node.content = symbolize_keys(node.content) if node.content.is_a?(Hash)
    symbolize_tree(node)
  end
  return tree
rescue  StandardError => e
  STDERR.puts e.to_s
end

def base_url
  'http://' + @core_api.get_registry_ip + ':4567'
rescue  StandardError => e
  STDERR.puts e.to_s
end

def read_stdin_data
  stdin_data = ""

  require 'timeout'
  status = Timeout::timeout(10) do
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

def get_json_stream(path)
  require 'yajl'
  chunk = ''

  uri = URI(@base_url + path_with_params(path, add_access(nil)))
  Net::HTTP.start(uri.host, uri.port)  do |http|
    req = Net::HTTP::Get.new(uri)
    parser = Yajl::Parser.new(:symbolize_keys => true)
    http.request(req) { |resp|
      resp.read_body do |chunk|
        begin
          next if chunk == "\0" || chunk == "\n"
          hash = parser.parse(chunk) do |hash|
            p hash
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

def get_stream(path)
  #require 'yajl'
  chunk = ''

  uri = URI(@base_url + path_with_params(path, add_access(nil)))
  Net::HTTP.start(uri.host, uri.port)  do |http|
    req = Net::HTTP::Get.new(uri)
    #  parser = Yajl::Parser.new
    http.request(req) { |resp|
      resp.read_body do |chunk|
        #hash = parser.parse(chunk) do |hash|
        puts chunk
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

def connection
  headers = {}
  headers['HTTP_ACCESS_TOKEN'] = ENV['access_token']
   @connection = Excon.new(@base_url,
                           :debug_request => true,
                           :debug_response => true,
                           :persistent => true,
                           :body => headers.to_json) if @connection.nil?
    @connection
 end
 
def rest_get(uri,params=nil)
  

connection.request(:method => :get,:path => uri) #,:body => params.to_json)
    rescue StandardError => e
  
      STDERR.puts e.to_s + ' with path:' + uri + "\n" + 'params:' + params.to_s
      STDERR.puts e.backtrace.to_s
 end
 
def handle_resp(resp, expect_json=true)
  parser = Yajl::Parser.new(:symbolize_keys => true)

  STDERR.puts(" RESPOSE " + resp.to_s)
   STDERR.puts(" RESPOSE " + resp.status.to_s + " : " + resp.body  )
   STDERR.puts("error:" + resp.status.to_s)  if resp.status  >= 400
   STDOUT.puts 'OK' if resp.status  == 204 # nodata but all good happens on del
  STDOUT.puts("Un exepect response from docker" + resp.status.to_s + ' ' +resp.body.to_s + ' ' + resp.headers.to_s )   unless resp.status  == 200 ||  resp.status  == 201
return resp.body.to_s unless expect_json == true
   hashes = []
   parser.parse(resp.body) do |hash |
     hashes.push(hash)
   end
  return hashes[0].to_s
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
  if r.headers[:content_type] == 'application/octet-stream'
    STDOUT.write( r.body.b)
    # STDERR.puts "as_binary"
  else
#    puts r.body.to_s
#    STDOUT.write(r.body)
#    puts 'bb'
    expect_json=false
    expect_json=true if r.headers[:content_type] == 'application/json'
   puts handle_resp(r, expect_json)
  end

end

def rest_post(path, params, content_type )

  begin
     
   # params = add_access(params)
    #STDERR.puts('Post Path:' + path.to_s + ' Params:' + params.to_s)
    params = params.to_json if content_type == 'application/json'
    r = RestClient.post(@base_url + path, params, { :content_type => content_type, :access_token => load_token} )

    write_response(r)
    exit
  rescue RestClient::ExceptionWithResponse => e
    parse_error(e.response)
  rescue StandardError => e
    params[:api_vars][:data] = nil
    STDERR.puts e.to_s + ' with path:' + path + "\n" + 'params:' + params.to_s
    STDERR.puts r.to_s
  end
end

def rest_delete(path, params=nil)
  params = add_access(params)
  begin
    #STDERR.puts('Post Path:' + path.to_s + ' Params:' + params.to_s)
    r = RestClient.delete(@base_url + path, params) #, {  :access_token => load_token} )
    write_response(r)
    exit
  rescue RestClient::ExceptionWithResponse => e
    parse_error(e.response)
  rescue StandardError => e
    STDERR.puts e.to_s + ' with path:' + path + "\n" + 'params:' + params.to_s
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
  ENV['access_token'].strip
end

def  process_args
  
end

@base_url = 'http://' + ENV['DOCKER_IP'] + ':2380'
@host = ENV['DOCKER_IP']
@port = '2380'
@route = "/v0"

load_token

login if ENV['access_token'].nil?

 process_args
  
  
require_relative 'commands/commands.rb'

#require_relative 'rset.rb'

