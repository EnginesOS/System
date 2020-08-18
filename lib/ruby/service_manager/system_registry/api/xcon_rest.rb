class SystemRegistryClient
  require '/opt/engines/lib/ruby/exceptions/registry_exception.rb'
  require 'ffi_yajl'

  def json_parser
    @json_parser ||= FFI_Yajl::Parser.new({:symbolize_keys => true})
  end

  def headers (content_type = nil)
    @headers = {'content_type' => 'application/json','ACCESS_TOKEN' => 'atest_randy', 'Accept' => '*/*'} if @headers.nil?
    @headers['content_type'] = content_type unless content_type.nil?
    @headers
  end

  def connection(content_type = nil)
    @connection =  Excon.new(base_url,
    debug_request:  true,
    debug_response: true,
    ssl_verify_peer: false,
    persistent: true, #was false when threaded
    headers: headers(content_type) ) if @connection.nil?
    @connection
  rescue Errno::EHOSTUNREACH
    core.fix_registry_problem
    retry
  rescue StandardError => e
    raise EnginesException.new(error_hash("Failed to open connection to registry  #{e}\n#{e.backtrace}\n #{base_url}\n #{params}" , params))
  end

  def close_connection
    @connection.reset unless @connection.nil?
    @connection = nil
  end

  def reopen_connection
    @connection.reset unless @connection.nil?
    @connection = nil
    @connection = connection
    @connection
  end

  def rest_get(path, params = nil, time_out = 120, _headers = nil)
    cnt = 0
    q = query_hash(params)
    lheaders = headers
    lheaders.merge(_headers) unless _headers == nil
    lheaders.delete('Content-Type' ) if q.nil?
    req = {time_out: time_out, method: :get, path: "#{@route_prefix}#{path}", headers: lheaders }
    req[:query] = q unless q.nil?
    r = connection.request(req)
    parse_xcon_response(r)
  rescue Excon::Error::Socket => e
    reopen_connection
    #STDERR.puts(e.class.name + 'Excon::Error::Socket with path:' + path.to_s + "\n" + 'params:' + q.to_s + ':::' + req.to_s  + ':' + e.to_s)
    cnt += 1
    retry if cnt < 5
  rescue StandardError => e
    close_connection
  raise EnginesException.new(error_hash("reg get exception  #{e.to_s}\n #{e.backtrace}\n #{base_url}\n #{params}" , params))
  end

  def time_out
    120
  end

  def post(path, params = nil, lheaders = nil)
    cnt = 0
    begin
      # SystemDebug.debug(SystemDebug.registry,'POST  ', path.to_s + '?' + params.to_s)
      lheaders = headers if lheaders.nil?
      parse_xcon_response(connection.request({read_timeout: time_out, headers: lheaders, method: :post, path: "#{@route_prefix}#{path}", body: query_hash(params).to_json }))
    rescue Excon::Error::Socket => e
      unless e.socket_error == EOFError
        reopen_connection
        cnt += 1
        retry if cnt < 5
      end
    rescue StandardError => e
      STDERR.puts('BASE ur ' + base_url.to_s)
      STDERR.puts('path ' + path.to_s)
      STDERR.puts('exception ' + e.to_s)
      close_connection
    raise EnginesException.new(error_hash("reg Post exception  #{e}\n#{e.backtrace}\n #{base_url}\n #{params}" , params))
    end
  end

  def put(path, params = nil, lheaders = nil)
    cnt = 0
    lheaders = headers if lheaders.nil?
    parse_xcon_response( connection.request(read_timeout: time_out, headers: lheaders, method: :put, path: "#{@route_prefix}#{path}", query: query_hash(params).to_json ))
  rescue Excon::Error::Socket => e
    reopen_connection
    cnt += 1
    retry if cnt < 5
  rescue StandardError => e
    close_connection
    raise EnginesException.new(error_hash("reg put exception  #{e}\n#{e.backtrace}\n #{base_url}\n #{params}" , params))
  end

  def query_hash(params)
    if params.nil?
      nil
    elsif params.key?(:params)
      params[:params]
    else
      params
    end
  end

  def delete(path, params = nil, lheaders = nil)
    cnt = 0
    q = query_hash(params)
    # SystemDebug.debug(SystemDebug.registry, 'DEL ', path.to_s + '?' + q.to_s)
    lheaders = headers if lheaders.nil?
    parse_xcon_response( connection.request(read_timeout: time_out, headers: lheaders, method: :delete, path:"#{@route_prefix}#{path}", query: q))
  rescue Excon::Error::Socket => e
    reopen_connection
    cnt += 1
    retry if cnt < 5
  rescue StandardError => e
    raise EnginesException.new(error_hash("reg delete exception  #{e}\n#{e.backtrace}\n #{base_url}\n #{params}" , params))
  ensure
    close_connection
  end

  private

  def parse_xcon_response(resp)
    raise RegistryException.new({status: 400, error_mesg: 'Server Error', exception: :exception}) if resp.nil?
    error_result_exception(resp) if resp.status > 399
    r = resp.body
    unless r.nil?
      r.strip!
      unless resp.headers['Content-Type'] == 'plain/text'
        r = json_parser.parse(r)
        r = r[:BooleanResult] if r.is_a?(Hash) && r.key?(:BooleanResult)
      end
    end
    r
  end

  def error_result_exception(resp)
    body = resp.body unless resp.nil?
    if resp.headers.nil? || resp.headers['Content-Type'] != 'application/json'
      raise RegistryException.new(
      {status: resp.status,
        error_type: :error,
        error_mesg: 'Route Not Found',
        params: body
      })
    else
      begin
        r = json_parser.parse(body)
      rescue
        r = {}
      end
      STDERR.puts("RRRRR #{r}")
      r[:status] = resp.status
      r[:status] = 403 if r[:status].nil?
      raise RegistryException.new(
      {status: r[:status],
        error_type: :warning,
        error_mesg: 'RegistryException',
        params: r,
        raw: body
      })
    end
    #
  end

  def base_url
    "http://#{core.registry_root_ip}:4567"
  rescue  StandardError => e
    raise EnginesException.new('Cannot Determine Base URL' + e.to_s)
  end
end
