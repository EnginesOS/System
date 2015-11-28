require 'uri'
require 'yajl/http_stream'

uri = URI.parse("/var/run/docker.sock/events")
Yajl::HttpStream.get(uri, :symbolize_keys => true) do |hash|
  puts hash.inspect
end
