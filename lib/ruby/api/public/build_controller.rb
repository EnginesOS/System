class BuildController
  require '/opt/engines/lib/ruby/engine_builder/engine_builder.rb'
  attr_reader :engine,
  :build_error,
  :build_params,
  :engine

  def initialize(api)
    @core_api = api
    @core_api.build_started(self)
    @build_log_stream = nil
    @build_error_stream = nil
    @engine = nil
    @build_error = 'none'
  end

  def build_from_docker(params)
  end

  def abort_build
    p :abort_build
        p  @current_builder
    @engine_builder.abort_build unless @engine_builder.nil?
  end
  
  def build_engine(params)
    p :builder_params
    p params
    @build_params = params
    SystemStatus.build_starting(@build_params)
    @engine_builder = get_engine_builder(@build_params)

    @engine = @engine_builder.build_from_blue_print
    @build_error = @engine_builder.last_error
    p :build_error
    p self.build_error
    build_failed(params, @build_error) if @engine.nil? || @engine == false
    build_failed(params, @build_error) unless @engine.is_a?(ManagedEngine)
    build_complete(@build_params)
    return @engine
  rescue StandardError => e
    build_failed(params, e.to_s)
  end

  def get_engine_builder_streams
    ([@build_log_stream, @build_error_stream])
  end

  def buildEngine(repository, host, domain_name, environment)
    @build_params = {}
    @build_params[:repository] = repository
    @build_params[:host] = host
    @build_params[:domain_name] = domain_name

    SystemStatus.build_starting(@build_params)
    @engine_builder= get_engine_builder_bfr(repository, host, domain_name, environment)
    @engine = @engine_builder.build_from_blue_print
    @build_error = @engine_builder.last_error
    return build_failed(@build_params, @build_error)  unless engine.is_a(ManagedEngine)
    @engine.save_state
    build_complete(@build_params)
    return @engine
  rescue StandardError => e
    build_failed(@build_params, e)
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
  #    @attached_services = []attr_accessor

  def reinstall_engine(engine)
    @build_params = {}
    @build_params[:engine_name] = engine.container_name
    @build_params[:domain_name] = engine.domain_name
    @build_params[:host_name] = engine.hostname
    @build_params[:software_environment_variables] = engine.environments
    @build_params[:http_protocol] = engine.protocol
    @build_params[:memory] = engine.memory
    @build_params[:repository_url] = engine.repository
    @build_params[:variables]  = engine.environments
    SystemStatus.build_starting(@build_params)
    @engine_builder = get_engine_builder(@build_params)
    return build_failed(params, 'No Builder') unless @engine_builder.is_a?(EngineBuilder)
    @engine = @engine_builder.build_from_blue_print
    @build_error = @engine_builder.last_error
    return build_failed(@build_params, @build_error) unless @engine.is_a?(ManagedEngine)
    return build_failed(@build_params, @build_error) unless @engine.is_active?
    build_complete(@build_params)
    return @engine
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
    @build_params = {}
    @build_params[:repository] = repository
    @build_params[:host_name] = host
    @build_params[:domain_name] = domain_name
    @build_params[:environment] = environment
    get_engine_builder(@build_params)
  end

  def build_failed(params,err)
    params[:error] = err.to_s
    @build_error = err
    @core_api.build_stoped()   
    SystemUtils.log_error_mesg(err.to_s,params)
    SystemStatus.build_failed(params)
    EnginesOSapiResult.failed(params[:engine_name], err, caller_locations(1,1)[0].label)
  end
  
  def build_complete(build_params)
    @core_api.build_stoped()
    SystemStatus.build_complete(build_params)    
  end
end
