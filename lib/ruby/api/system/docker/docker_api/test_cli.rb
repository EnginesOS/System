class DockerApiTest

require_relative 'docker_api.rb'

api = DockerApi.new()

 def received_chuck(chunk)
   p chunk
 end

def test
  api.get_event_stream(self)
end

end
  
test = DockerApiTest.new
Thread.new {test.test}
sleep 1000
