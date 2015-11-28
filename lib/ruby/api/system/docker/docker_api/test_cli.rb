require 'uri'
require 'yajl/http_stream'

socket = UNIXSocket.new('/var/run/docker.sock')
socket.puts('GET /events')
parser = Yajl::Parser.new
hash = parser.parse(socket, :symbolize_keys => true) do |hash|
puts hash.inspect

end
