class DockerApi  < ErrorsApi
  #require '/opt/engines/lib/ruby/system/deal_with_json.rb'
  require_relative 'docker_connection.rb'
  require '/opt/engines/lib/ruby/exceptions/docker_exception.rb'
  require_relative 'docker_api_errors.rb'
  include EnginesDockerApiErrors

  def initialize
    @con = DockerConnection.new
  end

  def get_event_stream(handler,filter=nil )
    @con.request_stream('/events',filter,handler)
  end

end