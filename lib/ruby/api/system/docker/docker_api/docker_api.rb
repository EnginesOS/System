class DockerApi  < ErrorsApi
  require '/opt/engines/lib/ruby/system/deal_with_json.rb'
  require_relative 'docker_connection.rb'

  require_relative 'docker_api_errors.rb'
  include EnginesDockerApiErrors
 
  
    
  def initialize
    @con = DockerConnection.new
  
  end

  def get_event_stream(handler,filter=nil )
    @con.request_stream('/events',filter,handler)
 
  end

  #
  # def create_container(container)
  #   params = create_options(container)
  #   SystemDebug.debug(SystemDebug.containers,  params.to_s)
  #
  #
  # end

end