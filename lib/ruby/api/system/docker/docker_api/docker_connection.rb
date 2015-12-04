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
  
  def inspect_container(container)
#    p :test_inspect 
#    p container.container_name
   # puts 'id_' + container.container_id.to_s + '_' 
    container.set_cont_id if container.container_id.to_s == '-1' || container.container_id.nil?
    return nil if container.container_id.to_s == '-1' || container.container_id.nil?
    request='/containers/' + container.container_id.to_s + '/json'
      p :requesting
      p request
   return make_request(request, container)       
    rescue StandardError =>e
      log_exception(e)
  end
  
  
  def make_request(uri, container)
  req = Net::HTTP::Get.new(uri)
  resp = docker_socket.request(req)
#  p resp
#    chunks = ''
  chunk = resp.read_body 
  rhash = nil
  hashes = []
  chunk.gsub!(/\\\"/,'')
  return clear_cid(container) if chunk.start_with?('no such id: ')
  response_parser.parse(chunk) do |hash |
    hashes.push(hash)   
  end 

#   hashes[1] is a timestamp
  return hashes[0]        
  rescue StandardError => e
    log_exception(e)
    return hashes[0]        
  end
  
  private

  def clear_cid(container)
  puts '++++++++++++++++++++++++++Cleared Cid'
    File.delete(SystemConfig.CidDir + '/' + container.container_name + '.cid')  if File.exists?(SystemConfig.CidDir + '/' + container.container_name + '.cid') 
    container.clear_cid
    return false 
  end
end