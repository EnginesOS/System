class DockerConnection < ErrorsApi
  #require 'rest-client'
  require 'yajl'
  require 'net_x/http_unix'
  require 'socket'

  attr_accessor :response_parser

  def initialize
    @response_parser = Yajl::Parser.new

    #socket = UNIXSocket.new('/var/run/docker.sock')

    @docker_socket = docker_socket
  rescue StandardError => e
    log_exception(e)
  end

  def container_id_from_name(container)
    # request='/containers/json?son?all=false&name=/' + container.container_name
    request='/containers/json' #?filter=Names=/' + container.container_name
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
    id = container_id_from_name(container)
    return false if id == -1
    request='/containers/' + id.to_s + '/json'
    r =  make_request(request, container)
    SystemDebug.debug(SystemDebug.containers,'inspect_container_by_name',container.container_name,r)
    return r  if r.is_a?(FalseClass)
    r = r[0] if r.is_a?(Array)
    return false if r.key?('RepoTags') #No container by that name and it will return images by that name WTF
    return r
  rescue StandardError  => e
    log_exception(e)
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

  def make_request(uri, container)
    req = Net::HTTP::Get.new(uri)
    resp = docker_socket.request(req)
    #FIXMe check the value of resp.code
    #    chunks = ''
    #  puts resp.code       # => '200'
    #   puts resp.message    # => 'OK'
    #  SystemDebug.debug(SystemDebug.docker, 'resp  ' ,resp, ' from ', uri)
    if  resp.code  == '404'
      chunk = resp.read_body
      clear_cid(container) if chunk.start_with?('no such id: ')
      return log_error_mesg("no  such id response from docker", resp, resp.read_body)
    end
    return log_error_mesg("no OK response from docker", resp, resp.read_body)   unless resp.code  == '200'
    chunk = resp.read_body

    rhash = nil
    hashes = []
    chunk.gsub!(/\\\"/,'')
    #SystemDebug.debug(SystemDebug.docker, 'chunk',chunk)
    return clear_cid(container) if chunk.start_with?('no such id: ')
    response_parser.parse(chunk) do |hash |
      hashes.push(hash)
    end

    #   hashes[1] is a timestamp
    return hashes[0]
  rescue StandardError => e
    log_exception(e,chunk)
  end

  private

  def docker_socket
    return @docker_socket unless @docker_socket.nil?
    @docker_socket = NetX::HTTPUnix.new('unix:///var/run/docker.sock')
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
  
def log_warn_mesg(mesg,*objs)
  return EnginesDockerApiError.new(e.to_s,:warning)
end

  def log_error_mesg(mesg,*objs)
    super
    return EnginesDockerApiError.new(e.to_s,:failure)
  end
  
  def log_exception(e,*objs)
    super
    return EnginesDockerApiError.new(e.to_s,:exception)
  end
end