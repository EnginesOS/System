class DockerConnection < ErrorsApi
  #require 'rest-client'
  require 'yajl'
  require 'net_x/http_unix'
  require 'socket'

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
  
  attr_accessor :response_parser

  def initialize
    @response_parser = Yajl::Parser.new
    @docker_socket = docker_socket
  rescue StandardError => e
    log_exception(e)
  end

  class DataProducer
    def initialize()
      @mutex = Mutex.new
      @body = ''
      @eof = false
    end

    def eof!()
      @eof = true
    end

    def eof?()
      @eof
    end

    def size
      @body.size
    end

    def read(size, offset)
      STDERR.puts(' READ PARAm ' + offset.to_s + ',' + size.to_s + ' from ' + @body )
      if @body.empty? && @eof
        nil
      else
        @mutex.synchronize {
          size =  @body.size - 1  if size >= @body.size

          b = @body.slice!(0,size)
          STDERR.puts(' write b ' + b.to_s + ' of ' + size.to_s + ' bytes  remaining str ' + @body.to_s )
          return b
        }
      end
    end

    def produce(data)
      @mutex.synchronize {
        @body = data
      }
    end
  end

  def perform_data_request(req, container, return_hash, data)
    producer = DataProducer.new
    #'Transfer-Encoding' => 'chunked', 'content-type' => 'text/plain'
    #

    req.content_type = "application/octet-stream" #"text/plain"
    req['Transfer-Encoding'] = 'chunked'
    req.content_length = data.length
    req.body_stream = producer
    t1 = Thread.new do
      producer.produce(data)
      producer.eof!
    end
    docker_socket.start {|http| http.request(req) }
  rescue StandardError => e
    log_exception(e)
  end

 
  def make_post_request(uri, container, params = nil, return_hash = true , data = nil)

    unless params.nil?
      initheader = {'Content-Type' =>'application/json'}
      req = Net::HTTP::Post.new(uri, initheader)
      STDERR.puts('Post REQUEST ' + uri.to_s + '::' + req.body.to_s )
      req.body = params.to_json

      #      c.gsub!(/\\"/,'"')
      #      c.gsub!(/^"/,'')
      #      c.gsub!(/"$/,'')
      STDERR.puts('Post REQUEST ' + req.body.to_s )
    else
      req = Net::HTTP::Post.new(uri)
    end
    return perform_data_request(req, container, return_hash, data) unless data.nil?
    perform_request(req, container, return_hash)
  rescue StandardError => e
    log_exception(e)
  end

  def make_request(uri, container, return_hash = true)
    req = Net::HTTP::Get.new(uri)
    STDERR.puts(' GET ' + uri.to_s)
    perform_request(req, container, return_hash)
  end

  def make_del_request(uri, container)
    req = Net::HTTP::Delete.new(uri)
    STDERR.puts(' Del ' + uri.to_s)
    perform_request(req, container)
  end

  def  perform_request(req, container, return_hash = true)
    tries=0
    r = ''
    begin
      resp = docker_socket.request(req)
      if  resp.code  == '404'
        clear_cid(container) if ! container.nil? && resp.body.start_with?('no such id: ')
        return log_error_mesg("no such id response from docker", resp, resp.body)
      end
      return false if resp.code  == '409'
      return true if resp.code  == '204' # nodata but all good
      STDERR.puts(' RESPOSE ' + resp.code.to_s + ' : ' + resp.msg  )
      return log_error_mesg("no OK response from docker", resp, resp.body, resp.msg )   unless resp.code  == '200' ||  resp.code  == '201'

      #    STDERR.puts(" CHUNK  " + resp.body.to_s + ' : ' + resp.msg )

      unless return_hash == true
        #      begin
        #      r = ''
        #      resp.read_body do |chunk|
        #              #hash = parser.parse(chunk) do |hash|
        #  STDERR.puts(" CHUNK  " + resp.body.to_s)
        #             r += chunk
        #              #end
        #            end
        #     return r
        #      rescue StandardError => e
        #        return r
        #      end
        return resp.body
      end
      r = resp.body
      hashes = []
      #  @chunk.gsub!(/\\\"/,'')
      #SystemDebug.debug(SystemDebug.docker, 'chunk',chunk)
      return clear_cid(container) if ! container.nil? && r.start_with?('no such id: ')
      response_parser.parse(r) do |hash |
        hashes.push(hash)
      end

      #   hashes[1] is a timestamp
      return hashes[0]

    rescue EOFError # also Bad file descriptor
      return r
    rescue StandardError => e
      return log_exception(e,r) if tries > 2
      log_exception(e,r)
      STDERR.puts(' RETRY RETRY ON ' + res.to_s + ' DUE to ' + e.to_s)
      tries += 1
      sleep 0.1
      retry
    end
  end

private

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