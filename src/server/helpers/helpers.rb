helpers do
  require_relative 'params.rb'
  require_relative 'output.rb'
  def engines_api
    $engines_api
  end

  def json_parser
    # @json_parser = Yajl::Parser.new(:symbolize_keys => true) if @json_parser.nil?
    @json_parser ||= FFI_Yajl::Parser.new(symbolize_keys: true)
  end

  def log_exception(e, *args)
    e_str = e.to_s
    e.backtrace.each do |bt|
      e_str += bt + ' \n'
    end
    e_str += ':' + args.to_s
    @@last_error = e_str.to_s
    STDERR.puts e_str
    SystemUtils.log_output(e_str, 10)
    f = File.open('/tmp/exceptions.' + Process.pid.to_s, 'a+')
    f.puts(e_str)
    f.close
    false
  end

  def send_encoded_exception(api_exception)#request, error_object, *args)
    api_exception[:exception] = fake_exception(api_exception) unless api_exception[:exception].is_a?(Exception)
    status_code = 404
    status_code = api_exception[:status] if api_exception.key?(:status)
    error_mesg = {
      error_object: {}
    }
    if request.is_a?(String)
      error_mesg[:route] = request
    else
      error_mesg[:route] = request.fullpath
    end
  #  error_mesg[:method] = request.method
    #error_mesg[:params_trunc]
    STDERR.puts('send_encoded_exception with request ' + request.to_s)
    if api_exception[:exception].is_a?(EnginesException)
      error_mesg[:error_object] = api_exception[:exception].to_h
      error_mesg[:params] = api_exception[:params].to_s
    elsif error_object.is_a?(Exception)
      error_mesg[:error_object] = api_exception[:exception].to_h
      error_mesg[:source] = api_exception[:exception].backtrace.to_s
      error_mesg[:error_mesg] = api_exception[:exception].to_s
      status_code = 500
    end
    STDERR.puts error_mesg.to_s
    return_json(error_mesg, status_code)
  rescue Exception => e
    STDERR.puts e.to_s + '  ' + e.backtrace.to_s
    #  send_encoded_exception(request: 'send_encoded_exception', exception: e, status: 500)
  end

  def fake_exception(api_exception)
    STDERR.puts('faking it' + api_exception.to_s)
    status_code = 404
       status_code = api_exception[:status] if api_exception.key?(:status)
       error_mesg = {
         error_object: {}
       }
       if request.is_a?(String)
         error_mesg[:route] = request
       else
         error_mesg[:route] = request.fullpath
       end
    error_mesg[:error_object] = api_exception[:exception].to_s
    return_json(error_mesg, status_code)
  end

  def get_engine(engine_name)
    engines_api.loadManagedEngine(engine_name)
  end

  def get_service(service_name)
    engines_api.loadManagedService(service_name)
  end

  def downcase_keys(hash)
    return hash unless hash.is_a? Hash
    hash.map{|k, v| [k.downcase, downcase_keys(v)] }.to_h
  end

  def managed_containers_to_json(containers)
    return_json_array(containers, 404) if containers.nil?
    if containers.is_a?(Array)
      res = []
      containers.each do |c|
        res.push(c.to_h)
      end
      return return_json_array(res)
    end
    return_json(c.to_h)
  end

  def managed_container_as_json(c)
    return_json(c, 404) if c.nil?
    return_json(c.to_h)
  end

  use Warden::Manager do |config|
    config.scope_defaults :default,
    strategies: [:access_token], # Set your authorization strategy
    action: '/v0/unauthenticated' # Route to redirect to when warden.authenticate! returns a false answer.
    config.failure_app = self
  end

  #  Warden::Manager.before_failure do |env, opts|
  #    env['REQUEST_METHOD'] = 'POST'
  #  end

  # Implement your Warden stratagey to validate and authorize the access_token.
  Warden::Strategies.add(:access_token) do
    def valid?
      # Validate that the access token is properly formatted.
      # Currently only checks that it's actually a string.
      request.env['HTTP_ACCESS_TOKEN'].is_a?(String) | params['access_token'].is_a?(String)
    end

    def is_token_valid?(token, ip = nil)
      $engines_api.is_token_valid?(token, ip)
    end

    def authenticate!
      # Authorize request if HTTP_ACCESS_TOKEN matches 'youhavenoprivacyandnosecrets'
      # Your actual access token should be generated using one of the several great libraries
      # for this purpose and stored in a database, this is just to show how Warden should be
      # set up.
      STDERR.puts('NO HTTP_ACCESS_TOKEN in header ') if request.env['HTTP_ACCESS_TOKEN'].nil?
      access_granted = is_token_valid?(request.env['HTTP_ACCESS_TOKEN']) # == $token
      !access_granted ? fail!('Could not log in') : success!(access_granted)
    end
  end

end
