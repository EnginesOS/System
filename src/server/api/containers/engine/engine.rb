# @!group /containers/engine/:engine_name

# @method get_engine
# @overload get '/v0/containers/engine/:engine_name'
# get engine
# @return [Hash]
# test cd /opt/engines/tests/engines_api/engine ; make engine
get '/v0/containers/engine/:engine_name' do
  begin
    engine = get_engine(params[:engine_name])
    managed_container_as_json(engine)
  rescue StandardError => e
    return_json(nil)
    # FIXME: Kludge for Gui on build
   # send_encoded_exception(request: request, exception: e)
  end
end

# @method get_engine_status
# @overload get '/v0/containers/engine/:engine_name/status'
# get engine status
# @return [Hash] :state :set_state :progress_to :error
# test cd /opt/engines/tests/engines_api/engine ; make status
get '/v0/containers/engine/:engine_name/status' do
  begin
    engine = get_engine(params[:engine_name])
    return_json(engine.status)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_engine_state
# @overload  get '/v0/containers/engine/:engine_name/state'
# get engine state
# @return [String] engine state
# test cd /opt/engines/tests/engines_api/engine ; make state
get '/v0/containers/engine/:engine_name/state' do
  begin
    engine = get_engine(params[:engine_name])
    return_text(engine.read_state)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_engine_blueprint
# @overload  get '/v0/containers/engine/:engine_name/blueprint'
# get engine blueprint
# @return [Hash]
# test cd /opt/engines/tests/engines_api/engine ; make blueprint
get '/v0/containers/engine/:engine_name/blueprint' do
  begin
    engine = get_engine(params[:engine_name])
    return_json(engine.load_blueprint)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_engine_build_report
# @overload   get '/v0/containers/engine/:engine_name/build_report'
# get engine build_report
# @return [String]
# test cd /opt/engines/tests/engines_api/engine ; make build_report
get '/v0/containers/engine/:engine_name/build_report' do
  begin
    return_text(engines_api.get_build_report(params[:engine_name]))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_engine_websites
# @overload   get '/v0/containers/engine/:engine_name/websites'
# get engine websites
# @return [String]
# test cd /opt/engines/tests/engines_api/engine ; make websites
get '/v0/containers/engine/:engine_name/websites' do
  begin
    engine = get_engine(params[:engine_name])
    return_json(engine.web_sites)
  rescue StandardError => e
    return_json(nil)
  end
end
# @method get_engine_logs
# @overload   get '/v0/containers/engine/:engine_name/logs'
# get engine logs
# @return [String]
# test cd /opt/engines/tests/engines_api/engine ; make logs
get '/v0/containers/engine/:engine_name/logs' do
  begin
    engine = get_engine(params[:engine_name])
    return_json(engine.logs_container)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_engine_ps
# @overload get '/v0/containers/engine/:engine_name/ps'
# get engine process lists
# @return [Hash] keys Processes:[Array] Titles:[Array]
# test cd /opt/engines/tests/engines_api/engine ; make ps
get '/v0/containers/engine/:engine_name/ps' do
  begin
    engine = get_engine(params[:engine_name])
    return_json(engine.ps_container)
  rescue
    send_encoded_exception(request: 'ps', exception: 'Container not running')
  end
end
# @!endgroup

