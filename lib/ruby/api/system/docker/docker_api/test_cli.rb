require 'yajl'
require 'net_x/http_unix'
require 'socket'
#socket = UNIXSocket.new('/var/run/docker.sock')
req = Net::HTTP::Get.new('/events')
client = NetX::HTTPUnix.new('unix:///var/run/docker.sock')
resp = client.request(req)
p resp.body

parser = Yajl::Parser.new
hash = parser.parse(resp.body) do |hash|
puts hash.inspect
  
end 
