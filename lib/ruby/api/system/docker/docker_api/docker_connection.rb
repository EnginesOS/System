class DockerConnection < ErrorsApi
  #require 'rest-client'
  require 'yajl'
  require 'net_x/http_unix'
  require 'socket'

  require_relative 'docker_api_errors.rb'
  include EnginesDockerApiErrors

  attr_accessor :response_parser

  def initialize
    @response_parser = Yajl::Parser.new
    @docker_socket = docker_socket
  rescue StandardError => e
    log_exception(e)
  end

  class DataProducer
    def initialize
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

    def read(size)
      @mutex.synchronize {
        @body.slice!(0,size)
      }
    end

    def produce(str)
      if @body.empty? && @eof
        nil
      else
        @mutex.synchronize { @body.slice!(0,size) }
      end
    end
  end

  def perform_data_request(req, container, return_hash, data)
    producer = DataProducer.new
    #    req.content_type = "multipart/form-data; boundary=60079"
    #    req.content_length = data.length
    req.body_stream = producer
    t1 = Thread.new do
      producer.produce(data)
      producer.eof!
    end
    docker_socket.start {|http| http.request(req) }
  end

  def docker_exec(container, command, log_error = true, data=nil)
    if command.is_a?(Array)
      commands = command
    else
      commands = [command]
    end

    request_params = {}
    if data.nil?
      request_params["AttachStdin"] = false
    else
      request_params["AttachStdin"] = true
    end
    request_params[ "AttachStdout"] =  false
    request_params[ "AttachStderr"] =  false
    request_params[ "DetachKeys"] =  "ctrl-p,ctrl-q"
    request_params["Tty"] =  false
    request_params[ "Cmd"] =  commands
    #request_params[ "Cmd"] = cmd
    request = '/containers/'  + container.container_id.to_s + '/exec'
    r = make_post_request(request, container, request_params)
    STDERR.puts('DOCKER EXEC ' + r.to_s + ': for :' + container.container_name + ': with :' + request_params.to_s)

    return r unless r.is_a?(Hash)

    exec_id = r['Id']
    request_params = {}
    request_params["Detach"] = false
    request_params["Tty"] = false
    request = '/exec/' + exec_id + '/start'
    r = make_post_request(request, container, request_params, false , data)

    STDERR.puts('EXEC RESQU ' + r.to_s)
    h = {}
    h[:stdout] = r
    h[:stderr] = ''
    # FIXME need to get correct error status and set :stderr if app
    h[:result] = 0
    h
  rescue StandardError => e
    STDERR.puts('DOCKER EXECep  ' + container.container_name + ': with :' + request_params.to_s)
    log_exception(e)
  end

  def container_id_from_name(container)
    # request='/containers/json?son?all=false&name=/' + container.container_name
    request='/containers/' + container.container_name + '/json'
    containers_info = make_request(request, container)
    SystemDebug.debug(SystemDebug.containers, 'docker:container_id_from_name  ' ,container.container_name   )
    return -1 unless containers_info.is_a?(Array)
    containers_info.each do |info|
      #  SystemDebug.debug(SystemDebug.containers, 'container_id_from_name  ' ,info['Names'][0]  )
      if info['Names'][0] == '/' + container.container_name
        SystemDebug.debug(SystemDebug.containers, 'MATCHED container_id_from_name  ' ,info['Names'][0],info['Id']    )
        id = info['Id']
        return id
      end
    end
    return -1
  rescue StandardError => e
    log_exception(e)
  end

  def ps_container(container)
    id = container.container_id
    id = container_id_from_name(container) if id == -1
    request = '/containers/'  + id + '/top?ps_args=aux'
    r =  make_request(request, container)
    SystemDebug.debug(SystemDebug.containers,'ps_container',container.container_name,r)
    return r
  end

  def inspect_container_by_name(container)

    # container.set_cont_id if container.container_id.to_s == '-1' || container.container_id.nil?
    request = '/containers/' + container.container_name.to_s + '/json'
    return make_request(request, container)
  rescue StandardError => e
    log_exception(e)

    #    id = container_id_from_name(container)
    #    return EnginesDockerApiError.new('Missing Container id', :warning) if id == -1
    #    request='/containers/' + id.to_s + '/json'
    #    r =  make_request(request, container)
    #    SystemDebug.debug(SystemDebug.containers,'inspect_container_by_name',container.container_name,r)
    #    return r  if r.is_a?(EnginesError)
    #    r = r[0] if r.is_a?(Array)
    #    return EnginesDockerApiError.new('No Such Container', :warning) if r.key?('RepoTags') #No container by that name and it will return images by that name WTF
    #    return r
    #  rescue StandardError  => e
    #    log_exception(e)
  end

  def inspect_container(container)
    # container.set_cont_id if container.container_id.to_s == '-1' || container.container_id.nil?
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      # return inspect_container_by_name(container)
      return EnginesDockerApiError.new('Missing Container id', :warning)
    else
      request = '/containers/' + container.container_id.to_s + '/json'
    end
    return make_request(request, container)
  rescue StandardError => e
    log_exception(e)
  end

  def container_exist?(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      # return inspect_container_by_name(container)
      r = @docker_comms.inspect_container_by_name(container)
      return true if r.is_a?(Hash)
      return false
    else
      request = '/containers/' + container.container_id.to_s + '/json'
    end
    r = make_request(request, container)
    STDERR.puts('container_exists ' + r.to_s)
    return true if r.is_a?(Hash)
    return false
  rescue StandardError => e
    return false
  end

  def stop_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      return EnginesDockerApiError.new('Missing Container id', :warning)
    else
      stop_timeout = 25
      stop_timeout = container.stop_timeout unless container.stop_timeout.nil?
      request = '/containers/' + container.container_id.to_s + '/stop?t=' + stop_timeout.to_s
    end
    return make_post_request(request, container)
  rescue StandardError => e
    log_exception(e)
  end

  def start_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      return EnginesDockerApiError.new('Missing Container id', :warning)
    else
      request = '/containers/' + container.container_id.to_s + '/start'
    end
    return make_post_request(request, container)
  rescue StandardError => e
    log_exception(e)
  end

  def pause_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      return EnginesDockerApiError.new('Missing Container id', :warning)
    else
      request = '/containers/' + container.container_id.to_s + '/pause'
    end
    return make_post_request(request, container)
  rescue StandardError => e
    log_exception(e)
  end

  def unpause_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      return EnginesDockerApiError.new('Missing Container id', :warning)
    else
      request = '/containers/' + container.container_id.to_s + '/unpause'
    end
    return make_post_request(request, container)
  rescue StandardError => e
    log_exception(e)

  end

  def destroy_container(container)
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
      return EnginesDockerApiError.new('Missing Container id', :warning)
    else
      request = '/containers/' + container.container_id.to_s
    end
    return make_del_request(request, container)
  rescue StandardError => e
    log_exception(e)
  end

  def make_post_request(uri, container, params = nil, return_hash = true , data = nil)
    unless params.nil?
      initheader = {'Content-Type' =>'application/json'}
      req = Net::HTTP::Post.new(uri, initheader)
      STDERR.puts('REQUEST ' + uri.to_s + '::' + req.body.to_s )
      req.body = params.to_json

      #      c.gsub!(/\\"/,'"')
      #      c.gsub!(/^"/,'')
      #      c.gsub!(/"$/,'')
      STDERR.puts('REQUEST ' + req.body.to_s )
    else
      req = Net::HTTP::Post.new(uri)
    end
    return perform_data_request(req, container, return_hash, data) unless data.nil?
    perform_request(req, container, return_hash  )
  rescue StandardError => e
    log_exception(e)
  end

  def make_request(uri, container)
    req = Net::HTTP::Get.new(uri)
    perform_request(req, container)
  end

  def make_del_request(uri, container)
    req = Net::HTTP::Delete.new(uri)
    perform_request(req, container)
  end

  def  perform_request(req, container, return_hash = true)
    tries=0
    resp = docker_socket.request(req)
    if  resp.code  == '404'
      clear_cid(container) if ! container.nil? && resp.read_body.start_with?('no such id: ')
      return log_error_mesg("no such id response from docker", resp, resp.read_body)
    end
    return true if resp.code  == '204' # nodata but all good
    STDERR.puts(' RESPOSE ' + resp.code.to_s )
    return log_error_mesg("no OK response from docker", resp, resp.read_body, resp.msg )   unless resp.code  == '200' ||  resp.code  == '201'
    STDERR.puts(" CHUNK  " + resp.read_body.to_s + ' : ' + resp.msg )
    unless return_hash
      r = ''
      resp.read_body do |chunk|
              #hash = parser.parse(chunk) do |hash|
             r += chunk
              #end
            end
     return r
    end
    chunk = resp.read_body
    hashes = []
    #  @chunk.gsub!(/\\\"/,'')
    #SystemDebug.debug(SystemDebug.docker, 'chunk',chunk)
    return clear_cid(container) if ! container.nil? && chunk.start_with?('no such id: ')
    response_parser.parse(chunk) do |hash |
      hashes.push(hash)
    end

    #   hashes[1] is a timestamp
    return hashes[0]
  rescue StandardError => e
    log_exception(e,chunk) if tries > 2

    tries += 1
    sleep 0.1
    retry
  end

  def pull_image(container)

    unless container.is_a?(String)
    
    container.image_repo = 'registry.hub.docker.com' if  container.image_repo.nil?
    request =  '/images/?fromImage=' + container.image_repo  + '/' + container.image
    else
      request =  '/images/?fromImage=' + container
      container = nil
    end
    STDERR.puts(' pull  ' + request.to_s)
    r = make_post_request(request, container)
    STDERR.puts(' pull result ' + r.to_s)
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def image_exist_by_name?(image_name)
    request = '/images/' + image_name + '/json'
    r =  make_request(request, nil)
    return true if r.is_a?(Hash) && r.key?('id')
    STDERR.puts(' image_exist? res ' + r.to_s )
    return  false
  rescue StandardError => e
    log_exception(e)
  end

  def  image_exist?(container)
    return image_exist_by_name?(container) if container.is_a?(String)
    request = '/images/' + container.image + '/json'
    r =  make_request(request, container)
    return true if r.is_a?(Hash) && r.key?('id')
    STDERR.puts(' image_exist? res ' + r.to_s )
    return  false
  rescue StandardError => e
    log_exception(e)
  end

  def delete_container_image(container)
    request = '/images/' + container.image
    return make_del_request(request, container)
  rescue StandardError => e
    log_exception(e)
  end

  def delete_image(image_name)
    request = '/images/' + image_name
    return make_del_request(request, nil)
  rescue StandardError => e
    log_exception(e)
  end
  private

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

  def clear_cid(container)
    SystemDebug.debug(SystemDebug.docker, '++++++++++++++++++++++++++Cleared Cid')

    container.clear_cid
    return false
  rescue StandardError => e
    log_exception(e)
  end

  #now in sep module
  #def log_warn_mesg(mesg,*objs)
  #  return EnginesDockerApiError.new(e.to_s,:warning)
  #end
  #
  #  def log_error_mesg(mesg,*objs)
  #    super
  #    return EnginesDockerApiError.new(e.to_s,:failure)
  #  end
  #
  #  def log_exception(e,*objs)
  #    super
  #    return EnginesDockerApiError.new(e.to_s,:exception)
  #  end
end