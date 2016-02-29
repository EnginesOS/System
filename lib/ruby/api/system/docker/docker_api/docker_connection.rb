class DockerConnection < ErrorsApi
  #require 'rest-client'
  require 'yajl'
  require 'net_x/http_unix'
  require 'socket'

  attr_accessor :docker_socket,:response_parser

  def initialize
    @response_parser = Yajl::Parser.new

    #socket = UNIXSocket.new('/var/run/docker.sock')

    @docker_socket = NetX::HTTPUnix.new('unix:///var/run/docker.sock')
    @docker_socket.continue_timeout = 60
    @docker_socket.read_timeout = 60
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
  return false  
end

def inspect_container_by_name(container)
    id = container_id_from_name(container)
    return false if id == -1
     request='/containers/' + id.to_s + '/json'
    r =  make_request(request, container)
  SystemDebug.debug(SystemDebug.containers,'inspect_container_by_name',container.container_name,r)
    return r
    rescue StandardError  => e
  log_exception(e)
  return false
    end

  def inspect_container(container)
   # container.set_cont_id if container.container_id.to_s == '-1' || container.container_id.nil?
    if container.container_id.to_s == '-1' || container.container_id.to_s  == ''
     # return inspect_container_by_name(container)
      return false
    else
      request='/containers/' + container.container_id.to_s + '/json'
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
    return nil
  end

  private

  def clear_cid(container)
    SystemDebug.debug(SystemDebug.docker, '++++++++++++++++++++++++++Cleared Cid')
   
    container.clear_cid
    return false
    rescue StandardError => e
      log_exception(e)
      return nil
  end
end