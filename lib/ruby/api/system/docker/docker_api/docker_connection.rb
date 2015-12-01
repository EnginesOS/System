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
  
  def inspect_containt(container)
#    p :test_inspect 
#    p container.container_name
    puts 'id_' + container.container_id.to_s + '_' 
    return nil if container.container_id.to_s == '-1' || container.container_id.nil?
    request='/containers/' + container.container_id.to_s + '/json'
#      p :requesting
#      p request
   return make_request(request)       
    rescue StandardError =>e
      log_exception(e)
  end
  
  
  def make_request(uri)
  req = Net::HTTP::Get.new(uri)
  resp = docker_socket.request(req)
#  p resp
#    chunks = ''
  chunk = resp.read_body 
#    resp.read_body do |chunk|
#      chunks += chunk
#    end
#  p chunk
#  puts 'chunk is a ' + chunk.class.name
  rhash = nil
  hashes = []
  chunk.gsub!(/\\\"/,'')
  response_parser.parse(chunk) do |hash |
#   p :hash
#   p hash
    hashes.push(hash)   
  end 
#  p :rhash
#  p hashes[0]
  return hashes[0]        
  rescue StandardError =>e
    log_exception(e)
    return hashes[0]        
  end
  
  private

end