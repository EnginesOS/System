helpers do
  require_relative 'params.rb'
  require_relative 'output.rb'
  def engines_api
    #$engines_api
    $engines_api ||= PublicApi.new(core_api)
  end

  def json_parser
    # @json_parser = Yajl::Parser.new(:symbolize_keys => true) if @json_parser.nil?
    @json_parser ||= FFI_Yajl::Parser.new(symbolize_keys: true)
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
      error_mesg[:method] = request.request_method
      error_mesg[:query] = request.query_string
      error_mesg[:params] = request.params
    end
    STDERR.puts('send_encoded_exception with request ' + api_exception.to_s)
    if api_exception[:exception].is_a?(EnginesException)
      error_mesg[:error_object] = api_exception[:exception].to_h
      error_mesg[:params] = api_exception[:params].to_s
    elsif api_exception[:exception].is_a?(Exception)
      error_mesg[:error_object] = {error_mesg: api_exception[:exception].to_s, error_type: :failure}
      error_mesg[:source] = api_exception[:exception].backtrace.to_s
      #  error_mesg[:error_mesg] = api_exception[:exception].to_s
      status_code = 500
    elsif api_exception[:exception].to_s == 'unauthorised'
      status_code = 401
    end
    STDERR.puts error_mesg.to_s
    return_json(error_mesg, status_code)
  rescue Exception => e
    STDERR.puts e.to_s + '  ' + e.backtrace.to_s
    #  send_encoded_exception(request: 'send_encoded_exception', exception: e, status: 500)
  end

  def fake_exception(api_exception)
    STDERR.puts('faking it' + api_exception.to_s)
    STDERR.puts(caller[0..10].to_s)
    if api_exception.to_s == 'unauthorised'
      status_code = 403
      STDERR.puts('faking unauthorised')
    else
      status_code = 404
    end
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
    return_text(error_mesg, status_code)
  end

  def get_engine(engine_name)
    engines_api.loadManagedEngine(engine_name)
  end

  def get_utilty(utilty_name)
    engines_api.loadManagedUtilty(utilty_name)
  end

  def get_service(service_name)
    engines_api.loadManagedService(service_name)
  end

  def downcase_keys(hash)
    return hash unless hash.is_a? Hash
    hash.map{|k, v| [k.downcase, downcase_keys(v)]}.to_h
  end

  def managed_containers_to_json(containers)
    return_json_array(containers, 404) if containers.nil?
    if containers.is_a?(Array)
      res = []
      containers.each do |c|
        res.push(c.to_h)
      end
      return_json_array(res)
    else
      return_json(c.to_h)
    end
  end

  def managed_container_as_json(c)
    return_json(c.to_h)
  end

  use Warden::Manager do |config|
    config.scope_defaults :default,
    strategies: [:access_token], # Set your authorization strategy
    action: '/v0/unauthenticated' # Route to redirect to when warden.authenticate! returns a false answer.
    config.failure_app = self
  end

  # Implement your Warden stratagey to validate and authorize the access_token.
  Warden::Strategies.add(:access_token) do
    def valid?
      request.env['HTTP_ACCESS_TOKEN'].is_a?(String)
    end

    def is_token_valid?(token, ip = nil)
      #$
      $engines_api.is_token_valid?(token, ip)
    end
    def failed
      STDERR.puts('FAILED ')
     # status (401)
      redirect! '/v0/unauthenticated'
      #throw(:warden, action: '/v0/unauthenticated')
    end
    def authenticate!
      STDERR.puts('NO HTTP_ACCESS_TOKEN in header ') if request.env['HTTP_ACCESS_TOKEN'].nil?
      access_granted = is_token_valid?(request.env['HTTP_ACCESS_TOKEN'])
   #   !access_granted ? fail!('Could not log in') : success!(access_granted)
      !access_granted ? failed : success!(access_granted)
    end
  end

end
