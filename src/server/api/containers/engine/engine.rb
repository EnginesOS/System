# @!group /containers/engine/:engine_name

# @method get_engine
# @overload get '/v0/containers/engine/:engine_name'
# get engine
# @return [Hash]
get '/v0/containers/engine/:engine_name' do
  begin
    engine = get_engine(params[:engine_name])
    managed_container_as_json(engine)
  rescue StandardError => e
    log_error(request, e)
  end
end

# @method get_engine_status
# @overload get '/v0/containers/engine/:engine_name/status'
# get engine status
# @return [Hash] :state :set_state :progress_to :error
get '/v0/containers/engine/:engine_name/status' do
  begin
    engine = get_engine(params[:engine_name])
    return log_error(request, engine, params) if engine.nil?
    r = engine.status
    return_json(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method get_engine_state
# @overload  get '/v0/containers/engine/:engine_name/state'
# get engine state
# @return [String] engine state
get '/v0/containers/engine/:engine_name/state' do
  begin
    engine = get_engine(params[:engine_name])
    return log_error(request, engine, params) if engine.nil?
    r = engine.read_state
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method get_engine_blueprint
# @overload  get '/v0/containers/engine/:engine_name/blueprint'
# get engine blueprint
# @return [Hash]
get '/v0/containers/engine/:engine_name/blueprint' do
  begin
    engine = get_engine(params[:engine_name])
    return log_error(request, engine, params) if engine.nil?
    r = engine.load_blueprint
    return_json(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method get_engine_build_report
# @overload   get '/v0/containers/engine/:engine_name/build_report'
# get engine build_report
# @return [String]
get '/v0/containers/engine/:engine_name/build_report' do
  begin
    r = engines_api.get_build_report(params[:engine_name])
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method get_engine_websites
# @overload   get '/v0/containers/engine/:engine_name/websites'
# get engine websites
# @return [String]
get '/v0/containers/engine/:engine_name/websites' do
  begin
    engine = get_engine(params[:engine_name])
    return log_error(request, engine, params) if engine.nil?
    r = engine.web_sites
    return_json(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method get_engine_logs
# @overload   get '/v0/containers/engine/:engine_name/logs'
# get engine logs
# @return [String]
get '/v0/containers/engine/:engine_name/logs' do
  begin
    engine = get_engine(params[:engine_name])
    return log_error(request, engine, params) if engine.nil?
    r = engine.logs_container
    return_json(r)
  rescue StandardError => e
    log_error(request, e)
  end
end

# @method get_engine_ps
# @overload get '/v0/containers/engine/:engine_name/ps'
# get engine process lists
# @return [Hash] keys Processes:[Array] Titles:[Array]
get '/v0/containers/engine/:engine_name/ps' do
  begin
    engine = get_engine(params[:engine_name])
    return log_error(request, engine, params) if engine.nil?
    r = engine.ps_container
    return_json(r)
  rescue
    log_error(request, 'Container not running', 'Container not running')
  end
end
# @!endgroup

