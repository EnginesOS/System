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
  rescue StandardError =>e
    log_exception(e)
  end
  
  def container_id_from_name(container)
    request='/containers/json?filter=name=' + container.container_name
    info = make_request(request, container)
    SystemDebug.debug(SystemDebug.containers, 'container_id_from_name  ' ,request, info)
    return false unless info.is_a(Array)

    id = id[0]
    id = info['Id']    
      return id
rescue 
  return false  
end

def inspect_container_by_name(container)
    id = container_id_from_name(container)
    return false if id false
     request='/containers/json?filter=name=' + container.container_name
    return make_request(request, container)
    rescue
  return false
    end

  def inspect_container(container)
   # container.set_cont_id if container.container_id.to_s == '-1' || container.container_id.nil?
    if container.container_id.to_s == '-1' || container.container_id.nil?
      return inspect_container_by_name(container)
    else
      request='/containers/' + container.container_id.to_s + '/json'
    end
    return make_request(request, container)
  rescue StandardError =>e
    log_exception(e)
  end

  def make_request(uri, container)
    req = Net::HTTP::Get.new(uri)
    resp = docker_socket.request(req)
    #FIXMe check the value of resp.code
    #    chunks = ''
    #  puts resp.code       # => '200'
    #   puts resp.message    # => 'OK'
    SystemDebug.debug(SystemDebug.docker, 'resp  ' ,resp, ' from ', uri)
    return log_error_mesg("no OK response from docker", resp, resp.read_body) unless  resp.code  == '200'
    chunk = resp.read_body

    rhash = nil
    hashes = []
    chunk.gsub!(/\\\"/,'')
   SystemDebug.debug(SystemDebug.docker,'Read ', chunk)
    return clear_cid(container) if chunk.start_with?('no such id: ')
    response_parser.parse(chunk) do |hash |
      hashes.push(hash)
    end

    #   hashes[1] is a timestamp
    return hashes[0]
  rescue StandardError => e
    log_exception(e)
    return nil
  end

  private

  def clear_cid(container)
    SystemDebug.debug(SystemDebug.docker, '++++++++++++++++++++++++++Cleared Cid')
    File.delete(SystemConfig.CidDir + '/' + container.container_name + '.cid')  if File.exists?(SystemConfig.CidDir + '/' + container.container_name + '.cid')
    container.clear_cid
    return false
  end
end