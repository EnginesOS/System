class DockerApi < ErrorsApi
  def default_headers
    @default_headers ||= {'Content-Type' =>'application/json', 'Accept' => '*/*'}
  end

  def post(p)
    fillin_params(p)
    p[:params] = p[:params].to_json if p[:headers]['Content-Type'] == 'application/json' && ! p[:params].nil?
  #  STDERR.puts('docker uri ' + p[:uri].to_s)
    @docker_api_mutex.synchronize {
      handle_resp(
      connection.request(
      method: :post,
      path: p[:uri],
      read_timeout: p[:timeout],
      headers: p[:headers],
      body: p[:params]),
      p[:expect_json])}
  end

  
  def post_stream_request(p)
    fillin_params(p)

    p[:content] = '' if p[:content].nil?
    sc = stream_connection(p)

    if p[:stream_handler].method(:has_data?).call == false
      if  p[:headers]['Content-Type'] == 'application/json'
        body = p[:content].to_json
      else
        body = p[:content]
      end
    else
      body = p[:content]
    end
    #    STDERR.puts({method: :post,
    #    read_timeout: p[:timeout],
    #    path: p[:uri] + '?' + p[:options].to_s,
    #    headers: p[:headers],
    #    body: body}.to_s)
    sc.request(
    method: :post,
    read_timeout: p[:timeout],
    path: "#{p[:uri]}?#{p[:options]}",
    headers: p[:headers],
    body: body
    )

  rescue Excon::Error::Socket => e
    STDERR.puts('Excon docker socket stream close ' + e.to_s)
  rescue  Excon::Error::Timeout => e
    STDERR.puts('Excon docker socket timeout ' + e.to_s)
  ensure
    p[:stream_handler].close unless p[:stream_handler].nil?
    sc.reset unless sc.nil?
  end

  def request_params(params)
    @request_params = params
  end

  def get_request(p)
    fillin_params(p)

    @docker_api_mutex.synchronize {
      handle_resp(
      connection.request(
      request_params(
      {
        method: :get,
        path: p[:uri],
        read_timeout: p[:timeout],
        headers: p[:headers]
      } )
      ), p[:expect_json])
    }
  rescue  Excon::Error::Socket =>e
    STDERR.puts(' docker get socket close ' + e.to_s)
  rescue  Excon::Error::Timeout =>e
    STDERR.puts(' docker get socket timeout ' + e.to_s)
    nil
  end

  def delete_request(p)
    @docker_api_mutex.synchronize {
      handle_resp(connection.request( {
        method: :delete,
        path: p[:uri],
        read_timeout: p[:timeout],
        headers: p[:headers]
      }),
      false
      ) }
  rescue  Excon::Error::Socket =>e
    STDERR.puts('docker delete socket close ' + e.to_s)
  rescue  Excon::Error::Timeout =>e
    STDERR.puts(' docker delete socket timeout ' + e.to_s)
    nil
  end

  private

  def handle_resp(resp, expect_json)
    raise DockerException.new({params: @request_param, status: 500}) if resp.nil?
    #SystemDebug.debug(SystemDebug.docker, 'Docker RESPOSE CODE' + resp.status.to_s )
    if resp.status > 399
      SystemDebug.debug(SystemDebug.docker, 'Docker RESPOSE CODE' + resp.status.to_s )
      SystemDebug.debug(SystemDebug.docker, 'Docker RESPOSE Body' + resp.body.to_s )
      SystemDebug.debug(SystemDebug.docker, 'Docker RESPOSE' + resp.to_s ) unless resp.status == 404
    end
    raise DockerException.new({params: @request_params, status: resp.status, body: resp.body}) if resp.status >= 400
    if resp.status == 204 # nodata but all good happens on del
      true
    else
      log_error_mesg("Un expected response from docker", resp, resp.body, resp.headers.to_s) unless resp.status == 200 || resp.status == 201
      if expect_json == true
        response_parser.parse(resp.body)
      else
        resp.body
      end
    end
  end

  def fillin_params(p)
    p[:headers] = default_headers if p[:headers].nil?
    p[:expect_json] = true unless p.key?(:expect_json)
    p[:read_timeout] = 180 unless p.key?(:read_timeout)
    p[:read_timeout] = p[:timeout] if p.key?(:timeout)
  end
end