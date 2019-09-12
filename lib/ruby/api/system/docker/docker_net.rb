module DockerNet
  require_relative 'hijack/docker_hijack.rb'
  def connection
    #  @connection =
    Excon.new('unix:///',
    :socket => '/var/run/docker.sock',
    debug_request: true,
    debug_response: true,
    persistent: false, #true  #,
    thread_safe_sockets: true
    )  #if @connection.nil?
    # @connection
  end

  def reopen_connection
    @connection.reset unless @connection.nil?
    #  SystemDebug.debug(SystemDebug.docker,' REOPEN doker.sock connection ')
    @connection = Excon.new('unix:///',
    :socket => '/var/run/docker.sock',
    debug_request: true,
    debug_response: true) #,
    #persistent: true,
    #thread_safe_sockets: true)
    @connection
  end

  def stream_connection(stream_reader)
    excon_params = {
      debug_request: true,
      debug_response: true,
      persistent: false,
      thread_safe_sockets: true
    }

    if stream_reader.method(:is_hijack?).call == true
      excon_params[:hijack_block] = DockerHijack.process_request(stream_reader)
    else
      excon_params[:response_block] = stream_reader.process_response
    end
    excon_params[:socket] = '/var/run/docker.sock'
    Excon.new('unix:///', excon_params)
  end
end