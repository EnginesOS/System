if @base_url.nil?

@host = ENV['DOCKER_IP'] if @host.nil?

@host = '172.17.0.1' if @host.nil? || @host.length < 3
@port = '2380' if @port.nil?
 unless ENV['CONTROL_HTTP'].nil? 
    @use_https = false
   @base_url = 'http://' +  @host + ':' + @port.to_s
  else
    @use_https = true
    @base_url = 'https://' +  @host + ':' + @port.to_s
end

  @base_url = 'http://' +  @host + ':' + @port.to_s if @base_url.nil?
  
  
@route = "/v0"
  end