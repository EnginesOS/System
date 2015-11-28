require 'uri'

require 'socket'
socket = UNIXSocket.new('/var/run/docker.sock')
socket.puts('GET /events')
parser = Yajl::Parser.new
hash = parser.parse(socket) do |hash|
puts hash.inspect

end 
