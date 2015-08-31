class BuildController
  def initialize(api)
    @core_api = api
    @build_log_stream = nil
    @build_error_stream = nil
  end

  def build_engine(params)
    p :builder_params
    p params
    SystemStatus.build_starting(params)
    engine_builder = get_engine_builder(params)
    engine = engine_builder.build_from_blue_print
    build_failed(params, engine_builder.last_error) if engine.nil? || engine == false
    build_failed(params, engine_builder.last_error) unless engine.is_a?(ManagedEngine)
    SystemStatus.build_complete(params)
    return engine
  rescue StandardError => e
    build_failed(params, engine_builder.last_error)
  end

  def get_engine_builder_streams
    ([@build_log_stream, @build_error_stream])
  end

  def buildEngine(repository, host, domain_name, environment)
    params = {}
    params[:repository] = repository
    params[:host] = host
    params[:domain_name] = domain_name
    SystemStatus.build_starting(params)
    engine_builder = get_engine_builder_bfr(repository, host, domain_name, environment)
    engine = engine_builder.build_from_blue_print
    return build_failed(params, engine_builder.last_error)  unless engine.is_a(ManagedEngine)
    engine.save_state
    SystemStatus.build_complete(params)
    return engine
  rescue StandardError => e
    build_failed(params, e)
  end
  
#  @core_api = core_api
#    params[:engine_name].gsub!(/ /, '_')
#    @container_name = params[:engine_name]
#    @domain_name = params[:domain_name]
#    @hostname = params[:host_name]
#    @http_protocol = params[:http_protocol]
#    @memory = params[:memory]
#    @repo_name = params[:repository_url]
#    return log_error_mesg('empty container name', params) if @container_name.nil? || @container_name == ''    
#    @container_name.freeze
#    @build_name = File.basename(@repo_name).sub(/\.git$/, '')
#    @web_port = SystemConfig.default_webport
#    @app_is_persistant = false
#    @result_mesg = 'Aborted Due to Errors'
#    @first_build = true
#    @attached_services = []

  def reinstall_engine(engine)
    params = {}
    params[:engine_name] = engine.container_name
    params[:domain_name] = engine.domain_name
    params[:host_name] = engine.hostname
    params[:software_environment_variables] = engine.environments
    params[:http_protocol] = engine.protocol
    params[:memory] = engine.memory
    params[:repository_url] = engine.repository
    SystemStatus.build_starting(params)
    builder = get_engine_builder(params)
    return build_failed(params, 'NO Builder') unless builder.is_a?(EngineBuilder)
    engine = builder.build_from_blue_print
    return build_failed(params, builder.last_error) unless engine.is_a?(ManagedEngine)
    return build_failed(params, builder.last_error) unless engine.is_active?
    SystemStatus.build_complete(params)
    return engine
  rescue StandardError => e
    build_failed(params, e)
    SystemUtils.log_exception(e)
  end

  private

  def get_engine_builder(params)
    builder = EngineBuilder.new(params, @core_api)
    @build_log_stream = builder.get_build_log_stream
    @build_error_stream = builder.get_build_err_stream
    return builder
  end

  def close_streams
    @build_log_stream = nil
    @build_error_stream = nil
  end

  def get_engine_builder_bfr(repository, host, domain_name, environment)
    params = {}
    params[:repository] = repository
    params[:host_name] = host
    params[:domain_name] = domain_name
    params[:environment] = environment
    get_engine_builder(params)
  end

  def build_failed(params,err)
    params[:error] = err.to_s
      SystemUtils.log_error_mesg(err.to_s,params)      
    SystemStatus.build_failed(params)
    EnginesOSapiResult.failed(params[:engine_name], err, caller_locations(1,1)[0].label)
  end
end
