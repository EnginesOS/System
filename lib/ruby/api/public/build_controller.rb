class BuildController < ErrorsApi
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
    SystemStatus.build_failed(params) if engine.nil? || engine == false
    SystemStatus.build_complete(params) if engine.is_a?(ManagedEngine)
    @last_error = engine_builder.last_error
    params[:error] = engine_builder.last_error
    return engine
  rescue StandardError => e
    @last_error = engine_builder.last_error if engine_builder.nil? == false && engine_builder.is_a?(EngineBuilder)
    @last_error = @last_error.to_s + ':Exception:' + e.to_s + ':' + e.backtrace.to_s
    p @last_error
    params[:error] = engine_builder.last_error
    SystemStatus.build_failed(params)
    return false
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
    if engine == false
      @last_error = @last_error.to_s
      params[:error] = engine_builder.last_error
      SystemStatus.build_failed(params)
      return false
    end
    if engine.nil? == false
      engine.save_state
      SystemStatus.build_complete(params)
      return engine
    end
    @last_error += @last_error.to_s
    params[:error] = engine_builder.last_error
    SystemStatus.build_failed(params)
    return false
  rescue StandardError => e
    @last_error = engine_builder.last_error if engine_builder.is_a?(EngineBuilder)
    @last_error = @last_error.to_s + ':Exception:' + e.to_s + ':' + e.backtrace.to_s
    params[:error] = @last_error
    SystemStatus.build_failed(params)
    return false
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
    builder = EngineBuilder.new(params, @core_api)
    @build_log_stream = builder.get_build_log_stream
    @build_error_stream = builder.get_build_err_stream
    return builder
  end
  
  def self.re_install_engine(engine, core)
     params = {}
     params[:engine_name] = engine.container_name
     params[:domain_name] = engine.domain_name
     params[:host_name] = engine.hostname
     params[:software_environment_variables] = engine.environments
     params[:http_protocol] = engine.protocol
     params[:memory] = engine.memory
     params[:repository_url] = engine.repo
     builder = EngineBuilder.new(params, core)
     if builder.is_a?(EngineBuilder) == false
       return  EnginesOSapiResult.failed(params[:engine_name], 'NO Builder', 'build_engine')
     end
     engine = builder.build_from_blue_print
     if engine == false
       #      builder.post_failed_build_clean_up Donnt do this as a reinstall should not delete on failure
       return  EnginesOSapiResult.failed(params[:engine_name], builder.last_error, 'build_engine')
     end
     if engine.nil? == false
       if engine.is_active? == false
         builder.close_all
         return EnginesOSapiResult.failed(params[:engine_name], 'Failed to start  ' + builder.last_error, 'Reinstall Engine')
       end
       return engine
     end
     builder.post_failed_build_clean_up
     return EnginesOSapiResult.failed(engine.container_name, builder.last_error, 'build_engine')
   rescue StandardError => e
     return EnginesOSapiResult.failed(engine.container_name, builder.last_error, 'build_engine')
   end

end
