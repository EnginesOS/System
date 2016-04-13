class DockerEventWatcher  < ErrorsApi

require 'yajl'
require 'net_x/http_unix'
require 'socket'

 def initialize(system)
 @system_api = system
 # FIXMe add conntection watcher that re establishes connection asap and continues trying after warngin ....
 end
 
 def start
   parser = Yajl::Parser.new

   req = Net::HTTP::Get.new('/events')
   client = NetX::HTTPUnix.new('unix:///var/run/docker.sock')
   client.continue_timeout=360000
   client.read_timeout=360000
   
  client.request(req) { |resp|
    chunk = ''
   resp.read_body do |chunk|
     hash = parser.parse(chunk) do |hash|
       p hash
      @system_api.container_event(hash) # if hash.key?('from')     
    end 
   end
 }
   rescue StandardError => e
     log_exception(e,chunk)
end 

  end