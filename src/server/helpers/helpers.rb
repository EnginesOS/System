helpers do
  require_relative 'params.rb'
  def engines_api
    $engines_api
  end

  def return_json(r, s=202)
    return return_error if r.is_a?(EnginesError)
    content_type 'application/json'
    status(s)
    return empty_json if r.nil?
    STDERR.puts("JSON " + r.to_json)
    r.to_json
  end

  def return_json_array(r, s=202)
    return return_error if r.is_a?(EnginesError)
    content_type 'application/json'
    status(s)
    return empty_array if r.nil?
    return empty_array if r.is_a?(FalseClass)
    #  STDERR.puts("JSON " + r.to_s)
    r
  end

  def return_text(r, s=202)
    return return_error if r.is_a?(EnginesError)
    content_type 'text/plain'
    STDERR.puts("text " + r.to_s)
    status(s)
    r.to_s
  end

  def return_true(s = 200)
    return return_error(s) if r.is_a?(EnginesError)
    return_text('true', s)
  end

  def return_error(error)
    status(404) # FixMe take this from the error if avail
    content_type 'application/json'
    error.to_json
  end

  def json_parser
    # @json_parser = Yajl::Parser.new(:symbolize_keys => true) if @json_parser.nil?
    @json_parser = FFI_Yajl::Parser.new({:symbolize_keys => true}) if @json_parser.nil?
    @json_parser
  end

  def empty_array
    @empty_array ||= [].to_json
  end

  def empty_json
    @empty_json ||= {}.to_json
  end

  def log_exception(e, *args)
    e_str = e.to_s()
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

  def log_error(request, error_object, *args)
    # return EnginesError.new(msg.to_s,:error)
    code = 404
    error_mesg = {}
    if request.is_a?(String)
      error_mesg[:route] = request
    else
      error_mesg[:route] = request.fullpath
    end
    error_mesg[:error_object] = error_object
    error_mesg[:mesg] = args[0] unless args.count == 0
    error_mesg[:args] = args.to_s unless args.count == 0
    code = args[args.count-1] if args[args.count-1].is_a?(Fixnum)

    STDERR.puts args.to_s + '::' + engines_api.last_error.to_s
    #  body args.to_s + ':' + engines_api.last_error.to_s
    if error_mesg[:mesg] == 'unauthorised'
      status(403)
    else
      status(code)
    end
    error_mesg.to_json
  end

  def get_engine(engine_name)
    eng = engines_api.loadManagedEngine(engine_name)
    # STDERR.puts("engine class " + eng.class.name + ':' + eng.to_json.to_s)
    return eng # if eng.is_a?(ManagedEngine)
    #    log_error('Load failed !!!', eng, eng.class.name, engine_name)

    #    return eng
  end

  def get_service(service_name)
    service = engines_api.loadManagedService(service_name)
    return service if service.is_a?(ManagedService) || service.is_a?(EnginesError)
    log_error('Load Service failed !!!' + service_name, service)
  end

  def  downcase_keys(hash)
    return hash unless hash.is_a? Hash
    hash.map{|k,v| [k.downcase, downcase_keys(v)] }.to_h
  end

  def managed_containers_to_json(containers)
    if containers.is_a?(Array)
      res = []
      containers.each do |container|
        res.push(container.to_h)
      end
      return return_json_array(res)
    end
    return_json(container.to_h)
  end

 

  use Warden::Manager do |config|
    config.scope_defaults :default,
    # Set your authorization strategy
    strategies: [:access_token],
    # Route to redirect to when warden.authenticate! returns a false answer.
    action: '/v0/unauthenticated'
    config.failure_app = self
  end

  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
  end

  # Implement your Warden stratagey to validate and authorize the access_token.
  Warden::Strategies.add(:access_token) do
    def valid?
      # Validate that the access token is properly formatted.
      # Currently only checks that it's actually a string.
      request.env["HTTP_ACCESS_TOKEN"].is_a?(String) | params['access_token'].is_a?(String)
    end

    def is_token_valid?(token, ip =nil)
      $engines_api.is_token_valid?(token, ip =nil)
    end

    def authenticate!
      # Authorize request if HTTP_ACCESS_TOKEN matches 'youhavenoprivacyandnosecrets'
      # Your actual access token should be generated using one of the several great libraries
      # for this purpose and stored in a database, this is just to show how Warden should be
      # set up.

      STDERR.puts("NO HTTP_ACCESS_TOKEN in header ") if request.env["HTTP_ACCESS_TOKEN"].nil?
      access_granted = is_token_valid?(request.env["HTTP_ACCESS_TOKEN"]) # == $token
      !access_granted ? fail!('Could not log in') : success!(access_granted)
    end
  end

end