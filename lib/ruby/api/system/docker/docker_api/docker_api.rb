class DockerApi  < ErrorsApi
  
  require_relative 'docker_connection.rb'
  require_relative 'docker_api_create_options.rb'
  include DockerApiCreateOptions
  
def initialize
  @con = DockerConnection.new
  
end

 def get_event_stream(handler,filter=nil )
   @con.request_stream('/events',filter,handler)
 end

 
 def create_container(container)
   params = create_options(container)
    p params.to_s
    
   
 end
 
end