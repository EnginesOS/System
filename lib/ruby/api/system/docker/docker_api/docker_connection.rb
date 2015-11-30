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
  end
  
  def test_inspect(container)
    p :test_inspect 
    p container.container_name
    p container.container_id.to_s
    return nil if container.container_id == -1
    request='/containers/' + container.container_id.to_s + '/json'
      p :requesting
      p request
   return make_request(request)
  end
  
  
  def make_request(uri)
  req = Net::HTTP::Get.new(uri)
  resp = docker_socket.request(req)
  p resp
  chunk = resp.read_body 
  hash = response_parser.parse(chunk) 
  p :hash
  p hash
  return hash        
  end
  
  private

end