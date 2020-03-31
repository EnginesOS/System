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
# @method set_engine_debug
# @overload get '/v0/containers/engine/:engine_name/set/debug'
# set engine debug
# @return [boolean]

put '/v0/containers/engine/:engine_name/debug/set' do
  begin
    engine = get_engine(params[:engine_name])
    return_boolean(engine.set_debug)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method clear_engine_debug
# @overload get '/v0/containers/engine/:engine_name/clear/debug'
# clear engine debug
# @return [boolean]
put '/v0/containers/engine/:engine_name/debug/clear' do
  begin
    engine = get_engine(params[:engine_name])
    return_boolean(engine.clear_debug)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
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

# @method get_engine_uptime
# @overload get '/v0/containers/engine/:engine_name/uptime'
# get engine uptime
# @return [Hash]
# test cd /opt/engines/tests/engines_api/engine ; make engine
get '/v0/containers/engine/:engine_name/uptime' do
  begin
    engine = get_engine(params[:engine_name])
    return_json({ 'uptime' => engine.uptime })
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
  rescue StandardError => e
    send_encoded_exception(request: 'ps', exception: e)
  end
end
# @method wait_for_engine
# @overload get '/v0/containers/engine/:engine_name/wait_for/:what'
#
# @return true|false
# test cd /opt/engines/tests/engines_api/engine ; make engine wait_for
get '/v0/containers/engine/:engine_name/wait_for/:what' do
  stream do |out|
    begin
      engine = get_engine(params[:engine_name])
      r = engine.wait_for(params[:what], 30)
      out << r.to_s unless out.closed?
      return_boolean(r)
    rescue StandardError => e
      out << false.to_s unless out.closed?
      send_encoded_exception(request: request, exception: e)
    end
  end
end
# @method wait_for_service_statup
# @overload get '/v0/containers/service/:service/wait_for_statup'
#
# @return true|false
# test cd /opt/engines/tests/engines_api/service ; make service wait_for_startup
get '/v0/containers/engine/:engine_name/wait_for_startup/:timeout' do
  stream do |out|
    begin
      engine = get_engine(params[:engine_name])
      r = engine.wait_for_startup(params[:timeout].to_i)
      out << r.to_s unless out.closed?
      return_boolean(r)
    rescue StandardError => e
      out << false.to_s unless out.closed?
      send_encoded_exception(request: request, exception: e)
    end
  end
end

# @method wait_for_engine_delat
# @overload get '/v0/containers/engine/:engine_name/wait_for/:what/:delay'
#
# @return true|false
# test cd /opt/engines/tests/engines_api/engine ; make engine wait_for
get '/v0/containers/engine/:engine_name/wait_for/:what/:delay' do
  stream do |out|
    begin
      engine = get_engine(params[:engine_name])
      r = engine.wait_for(params[:what], params[:delay].to_i)
      out << r.to_s unless out.closed?
      return_boolean(r)
    rescue StandardError => e
      out << false.to_s unless out.closed?
      send_encoded_exception(request: request, exception: e)
    end
  end
end

# @method clear_engine_error
# @overload get '/v0/containers/engine/:engine_name/clear'
#
# @return true|false

get '/v0/containers/engine/:engine_name/clear_error' do
  begin
    engine = get_engine(params[:engine_name])
    return_boolean(engines_api.user_clear_error(engine)) #engine.clear_error)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_icon_url
# @overload get '/v0/containers/engine/:engine_name/icon_url'
#
# @return String

get '/v0/containers/engine/:engine_name/icon_url' do
  begin
    engine = get_engine(params[:engine_name])
    return_text(engines_api.container_icon_url(engine.store_address))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method set_engine_icon_url
# @overload post '/v0/containers/engine/:engine_name/icon_url'
# Set the icon_url for :engine_name
# @param :icon_url

post '/v0/containers/engine/:engine_name/icon_url' do
  begin
    p_params = post_params(request)
    p_params[:engine_name] = params[:engine_name]
    engine = get_engine(p_params[:engine_name])
    cparams = assemble_params(p_params, [:engine_name], :icon_url)
    return_text(engines_api.set_container_icon_url(engine.store_address, cparams[:icon_url]))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @!endgroup
