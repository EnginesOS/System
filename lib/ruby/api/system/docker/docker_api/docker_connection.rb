class DockerConnection
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
  
  def test_inspect(container)
    p :test_inspect 
    p container.container_name
    puts 'id_' + container.container_id.to_s + '_' 
    return nil if container.container_id.to_s == '-1' || container.container_id.nil?
    request='/containers/' + container.container_id.to_s + '/json'
      p :requesting
      p request
   return make_request(request)       
    rescue StandardError =>e
      log_exception(e)
  end
  
  
  def make_request(uri)
  req = Net::HTTP::Get.new(uri)
  resp = docker_socket.request(req)
  p resp
  chunk = resp.read_body 
  p chunk
  puts 'chunk is a ' + chunk.class.name
  
  hash = response_parser.parse(chunk) 
  p :hash
  p hash
  return hash        
  rescue StandardError =>e
    log_exception(e)
  end
  
  private

end