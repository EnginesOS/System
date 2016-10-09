if @base_url.nil?

@host = ENV['DOCKER_IP'] if @host.nil?
@host = '127.0.0.1' if @host.length < 3
@port = '2380' if @port.nil?
@base_url = 'http://' +  @host + ':' + @port.to_s
@route = "/v0"
  end