class DockerEventWatcher  < ErrorsApi

require 'yajl'
require 'net_x/http_unix'
require 'socket'

 def initialize(system)
 @system_api = system
 

 end
 
 def start
   parser = Yajl::Parser.new
   
   #socket = UNIXSocket.new('/var/run/docker.sock')
   req = Net::HTTP::Get.new('/events')
   client = NetX::HTTPUnix.new('unix:///var/run/docker.sock')
   client.continue_timeout=360000
   client.read_timeout=360000
   
 client.request(req) { |resp|
#p resp
   resp.read_body do |chunk|
     #p chunk
     hash = parser.parse(chunk) do |hash|
    # puts hash.inspect
    #   p :___   
    #   event_name = hash['status'].gsub(/:.*$/,'')
     
   #  puts hash['from'].to_s + ' had event ' +  event_name 
   #  p :__return unless hash.key?('from')
      @system_api.container_event(hash)  if hash.key?('from')
      
    end 


   end

 }
   rescue StandardError => e
     log_exception(e)
end 

  end