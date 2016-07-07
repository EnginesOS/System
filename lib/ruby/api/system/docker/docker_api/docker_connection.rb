class DockerConnection < ErrorsApi
  #require 'rest-client'
  require 'yajl'
  require 'net_x/http_unix'
  require 'socket'
  
  require 'rubygems'
  require 'excon'

  require_relative 'docker_api_errors.rb'
  include EnginesDockerApiErrors
  require_relative 'docker_api_exec.rb'
  include DockerApiExec

  require_relative 'docker_api_container_actions.rb'
  include DockerApiContainerActions
  require_relative 'docker_api_container_status.rb'
  include DockerApiContainerStatus

  require_relative 'docker_api_images.rb'
  include DockerApiImages
  
  require_relative 'docker_api_container_ops.rb'
  include DockerApiContainerOps
  
  require_relative 'docker_api_builder.rb'
  include DockerApiBuilder
  
  attr_accessor :response_parser

  def initialize
    @response_parser = Yajl::Parser.new
    @docker_socket = docker_socket
    @socket_mutex = Mutex.new
    @connection = nil
  rescue StandardError => e
    log_exception(e)
  end

  

  require "base64"
  def get_registry_auth
    r = {}
    Base64.encode64(r.to_json)
  end
  
  def post_request(uri,  params = nil, expect_json = true )
    params = {} if params.nil?
   if data.nil?    
     return handle_resp(
                        connection.request(
                           :method => :post,:path => uri,
                           :headers => {'Content-Type' =>'application/json'},
                           :body =>  params.to_json  ), expect_json)  
   end
    
#    unless params.nil?
#      initheader = {'Content-Type' =>'application/json'}
#      req = Net::HTTP::Post.new(uri, initheader)
#      STDERR.puts('Post REQUEST ' + uri.to_s + '::' + req.body.to_s )
#      req.body = params.to_json
#
#      #      c.gsub!(/\\"/,'"')
#      #      c.gsub!(/^"/,'')
#      #      c.gsub!(/"$/,'')
#      STDERR.puts('Post REQUEST ' + req.body.to_s )
#    else
#      req = Net::HTTP::Post.new(uri)
#    end
#    return perform_data_request(req, container, return_hash, data) unless data.nil?
    #perform_request(req, container, return_hash, true)
  rescue StandardError => e
    log_exception(e)
  end

  def connection
    @connection = Excon.new('http://172.17.0.1:2375', 
                            :debug_request => true, 
                            :debug_response => true,
                            :persistent => true) if @connection.nil?
    @connection
  end
  
  def get_request(uri,  expect_json = true, headers = nil)
    return handle_resp(connection.request(:method => :get, 
                                          :path => uri, 
                                          :headers => headers), 
                                          expect_json) unless headers.nil?
                                          
    handle_resp(connection.request(:method => :get, 
                                   :path => uri), 
                                   expect_json)    
  end

  def delete_request(uri)
    handle_resp(connection.request(:method => :delete, 
                                   :path => uri), 
                                   false)  
#    req = Net::HTTP::Delete.new(uri)
#    STDERR.puts(' Del ' + uri.to_s)
#    perform_request(req, container, false, true)
  end
  
  private
  
  def  perform_request(req, container, return_hash = true , lock = false)
    tries=0
    r = ''
    begin
      # Fixme add Timeout
      # Fixme add mutex lock on docker_socker
      resp = ''
      if lock == true
        @socket_mutex.synchronize {
        resp = docker_socket.request(req)
        }
      else
        if @socket_mutex.locked?
          @socket_mutex.lock
          @socket_mutex.unlock          
        end          
        resp = docker_socket.request(req)
      end
      
      handle_response(resp,return_hash )
      
  
      rescue EOFError => e
        STDERR.puts(' EOFError' + req.to_s )
        return log_exception(e,r)
      rescue Errno::EBADF => e
          return log_exception(e,r) if tries > 2
  
            STDERR.puts(' EBADF RETRY ON ' + req.to_s +  '  DUE to ' + e.to_s)
            tries += 1
            sleep 0.1
            retry
  
      rescue StandardError => e
        return log_exception(e,r) if tries > 2
       
        STDERR.puts(' Exception ON perform_request' + req.to_s +  '  DUE to ' + e.to_s)
      return log_exception(e,r)
  #      tries += 1
  #      sleep 0.1
  #      retry
      
    end
    

  end

  def handle_response(resp, return_hash)
  #  return false  if  resp.code  == '404'
#      clear_cid(container) if ! container.nil? && resp.body.start_with?('no such id: ')
      return log_error_mesg("no such id response from docker", resp, resp.body) if  resp.code  == '404'
#    end
    return false if resp.code  == '409'
    return true if resp.code  == '204' # nodata but all good
    STDERR.puts(' RESPOSE ' + resp.code.to_s + ' : ' + resp.msg  )
    return log_error_mesg("no OK response from docker", resp, resp.body, resp.msg )   unless resp.code  == '200' ||  resp.code  == '201'

    r = resp.body
    return r unless return_hash == true

    hashes = []

 #   return clear_cid(container) if ! container.nil? && r.start_with?('no such id: ')
    response_parser.parse(r) do |hash |
      hashes.push(hash)
    end

    #   hashes[1] is a timestamp
    return hashes[0]
end
def handle_resp(resp, expect_json)
#   if  resp.status  == 404
#     clear_cid(container) if ! container.nil? && resp.body.start_with?('no such id: ')
#     return log_error_mesg("no such id response from docker", resp, resp.body)
#   end
   return log_error_mesg("error:" + resp.status.to_s)  if resp.status  >= 400
   return true if resp.status  == 204 # nodata but all good
   STDERR.puts(' RESPOSE ' + resp.status.to_s + ' : ' + resp.body  )
   return log_error_mesg("Un exepect response from docker", resp, resp.body, resp.headers.to_s )   unless resp.status  == 200 ||  resp.status  == 201

   r = resp.body
   return r unless expect_json == true

   hashes = []
  # return clear_cid(container) if ! container.nil? && r.start_with?('no such id: ')
   response_parser.parse(r) do |hash |
     hashes.push(hash)
   end

   #   hashes[1] is a timestamp
   return hashes[0]
rescue StandardError => e
  log_exception(e)
end

 def clear_cid(container)
   SystemDebug.debug(SystemDebug.docker, '++++++++++++++++++++++++++Cleared Cid')

   container.clear_cid
   return false
 rescue StandardError => e
   log_exception(e)
 end

  def docker_socket
    return @docker_socket unless @docker_socket.nil?
    #  @docker_socket = NetX::HTTPUnix.new('unix:///var/run/docker.sock')

    @docker_socket=  Net::HTTP.new('172.17.0.1', 2375)
    @docker_socket.continue_timeout = 60
    @docker_socket.read_timeout = 60
    return @docker_socket
  rescue StandardError => e
    log_exception(e,'Error opening unix:///var/run/docker.sock')
  end

 

end