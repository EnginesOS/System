class DockerApi
  
  require_relative 'docker_connection.rb'
  
def initialize
  @con = DockerConnection.new
  
end

 def get_event_stream(handler,filter=nil )
   @con.request_stream('/events',filter,handler)
 end

end