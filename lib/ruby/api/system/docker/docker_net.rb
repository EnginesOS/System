module DockerNet
  require_relative 'docker_hijack.rb'
  def connection
    #  @connection =
    Excon.new('unix:///',
    :socket => '/var/run/docker.sock',
    debug_request: true,
    debug_response: true,
    persistent: false, #true  #,
    thread_safe_sockets: true)
  end

  def reopen_connection
    @connection.reset unless @connection.nil?
    #  SystemDebug.debug(SystemDebug.docker,' REOPEN doker.sock connection ')
    @connection = Excon.new('unix:///',
    :socket => '/var/run/docker.sock',
    debug_request: true,
    debug_response: true) 
    @connection
  end

  def stream_connection(p)
    p[:stream_handler]
    excon_params = {
      debug_request: true,
      debug_response: true,
      persistent: false,
      thread_safe_sockets: true
    }
    excon_params[:read_timeout] = p[:timeout] if p.key?(:timeout)

    if p[:stream_handler].method(:is_hijack?).call == true
      excon_params[:hijack_block] = DockerHijack.process_request(p[:stream_handler])
    else
      excon_params[:response_block] = p[:stream_handler].process_response
    end
    excon_params[:socket] = '/var/run/docker.sock'
    Excon.new('unix:///', excon_params)
  end
end