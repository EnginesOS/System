if @base_url.nil?

@host = ENV['DOCKER_IP'] if @host.nil?
@host = '127.0.0.1' if @host.length < 3
@port = '2380' if @port.nil?
 unless ENV['CONTROL_HTTPS'].nil? 
    @use_https = true
   @base_url = 'https://' +  @host + ':' + @port.to_s
  else
    @use_https = false
    @base_url = 'http://' +  @host + ':' + @port.to_s
end

@route = "/v0"
  end