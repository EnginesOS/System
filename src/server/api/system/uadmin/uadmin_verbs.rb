def uconnection
  Excon.new( 'http://uadmin:8000',
  debug_request: true,
  debug_response: true,
  ssl_verify_peer: false,
  persistent: false,
  headers: {'content_type' => 'application/json'}) #content_type})
rescue Excon::Error => e
  STDERR.puts('Failed to open base url ' +   'http://uadmin:8000'  + ' ' + e.to_s + ' ' + e.class.name)
  if @retries < 5
    @retries += 1
    sleep 1
    retry
  end
  status(405)
rescue StandardError =>e
  STDERR.puts('Uncatch E ' + e.class.name + ' ' + e.to_s)
end

def handle_exeception(e)
  if e.is_a?(Excon::Error::Socket)
    status(405)
    {
      error_object: {
      error_mesg: 'Failed to open base url http://uadmin:8000'
      }
    }
  else
    status(405)
    {
      error_object: {
      error_mesg: e.class.name
      }
    }
  end
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
  STDERR.puts('Built ' + uri.to_s)
  uri
end

def uadmin_get(splat, params, body)
  body = process_body(body)
  c = uconnection
  c.request({method: :get,
    query: clean_params(params),
    body: body,
    path: build_uri(splat)})
rescue Exception => e
  handle_exeception(e)
ensure
  c.reset unless c.nil?
end

def uadmin_put(splat, params, body)
  c = uconnection
  rheaders = {}
  rheaders['content_type'] = 'application/json'

  body = process_body(body)
  c.request({method: :put,
    query: clean_params(params),
    path: build_uri(splat),
    headers: rheaders,
    body: body})
rescue Exception => e
  handle_exeception(e)
ensure
  c.reset unless c.nil?
end

def uadmin_post(splat, params, body)
  STDERR.puts( 'Post Body ' + body.to_s)

  rheaders = {}
  rheaders['content_type'] = 'application/json'
  body = process_body(body)
  c = uconnection
  r = {method: :post,
    query: clean_params(params),
    headers: rheaders,
    path: build_uri(splat),
    body: body}
  STDERR.puts('Request ' + r.to_s)
  c.request(r)
rescue Exception => e
  STDERR.puts( 'EXE ' + e.to_s)
  handle_exeception(e)
ensure
  c.reset unless c.nil?
end

def uadmin_del(splat, params, body)
  c = uconnection
  body = process_body(body)
  c.request({method: :delete,
    query: clean_params(params),
    body: body,
    path: build_uri(splat)})
rescue Exception => e
  handle_exeception(e)
ensure
  c.reset unless c.nil?
end

def uadmin_response(r)
  unless r.nil?
    unless r.is_a?(Excon::Response)
      r.to_json
    else
      STDERR.puts('Response got ' + r.to_s + ' headers ' + r.headers.to_s )
      content_type r.headers['Content-Type']
      status(r.status)
      STDERR.puts('Got Status ' + r.status.to_s)
      STDERR.puts('Got Content ' + r.body.to_s)
      r.body
    end
  end
end

def clean_api_vars(params)
  STDERR.puts('I got ' + params.to_s)
  v = clean_params(params)
  if v.nil?
    {}
  else
    STDERR.puts('I give ' +  v[:api_vars].to_s  )
    v[:api_vars]
  end
end

def process_body(body)
  STDERR.puts('RAW body ' + body.to_s)
  if body.is_a?(Hash)
    body =  body[:api_vars]
    body = body.to_json
    STDERR.puts('body to sned' + body.to_s)
  end
  body
end

def clean_params(params)
  if params.is_a?(Hash)
    params.delete('splat')
    params.delete('captures')
  end
  params
end