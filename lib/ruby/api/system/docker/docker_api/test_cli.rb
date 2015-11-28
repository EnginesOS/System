require 'yajl'
require 'net_x/http_unix'
require 'socket'
#socket = UNIXSocket.new('/var/run/docker.sock')
req = Net::HTTP::Get.new('/events')
client = NetX::HTTPUnix.new('unix:///var/run/docker.sock')

parser = Yajl::Parser.new
hash = parser.parse(client) do |hash|
puts hash.inspect

end 
