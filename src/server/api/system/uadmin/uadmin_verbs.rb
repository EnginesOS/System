def connection
  Excon.new( 'http://uadmin:8000',
  debug_request: true,
  debug_response: true,
  ssl_verify_peer: false,
  persistent: false,
  headers: {'content_type' => content_type})
rescue Excon::Error => e
  STDERR.puts('Failed to open base url ' +   'http://uadmin:8000'  + ' ' + e.to_s + ' ' + e.class.name)
  if @retries < 5
    @retries += 1
    sleep 1
    retry
  end
  STDERR.puts('Failed to open base url ' +  'http://uadmin:8000' + ' after ' + @retries.to_s = ' attempts')
rescue StandardError =>e
  STDERR.puts('Uncatch E ' + e.class.name + ' ' + e.to_s)
end

def build_uri(splat)
  uri = '/v0/'
  unless uri.is_a?(Array)
    uri = uri + splat.to_s
  else
    splat.each do | c |
      uri = uri + c.to_s
    end
  end
  uri
end

def uadmin_get(splat)
  c = connection
  c.request({method: :get, path: build_uri(splat)})
ensure
  c.reset unless c.nil?
end

def uadmin_put(splat, body)
  c = connection
  c.request({method: :get,
    path: build_uri(splat),
    body: body})
ensure
  c.reset unless c.nil?
end

def uadmin_post(splat, body)
  c = connection
  c.request({method: :get,
    path: build_uri(splat),
    body: body})
ensure
  c.reset unless c.nil?
end

def uadmin_del
  c = connection
  c.request({method: :delete, path: build_uri(splat)})
ensure
  c.reset unless c.nil?
end

def uadmin_response(r)
  content_type r.headers['Content-Type']
  status(r.status)
  r.body
end

