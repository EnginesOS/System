require 'yajl'
require 'net_x/http_unix'
require 'socket'

parser = Yajl::Parser.new

#socket = UNIXSocket.new('/var/run/docker.sock')
req = Net::HTTP::Get.new('/events')
client = NetX::HTTPUnix.new('unix:///var/run/docker.sock')
client.continue_timeout=36000
 client.request(req) { |resp|
#p resp
   resp.read_body do |chunk|
     #p chunk
     hash = parser.parse(chunk) do |hash|
    # puts hash.inspect
       p :___   
     p hash.to_s
     p :__
     end 


   end
 }

hash = parser.parse(resp.body) do |hash|
puts hash.inspect
  
end 
