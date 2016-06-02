
# @!group /containers/engine/:engine_name

# @method get_service
# @overload get '/v0/containers/engine/:engine_name' 
# get engine
# @return [Hash]
get '/v0/containers/engine/:engine_name' do
  engine = get_engine(params[:engine_name])
  unless engine.is_a?(EnginesError)
    STDERR.puts('got ' + engine.class.name)
    return  engine.to_h.to_json
  else
    return log_error(request,engine, params[:engine_name])
  end
end

# @method get_engine_status
# @overload get '/v0/containers/engine/:engine_name/status' 
# get engine status
# @return [Hash] :state :set_state :progress_to :error
get '/v0/containers/engine/:engine_name/status' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.status
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end
# @method get_engine_state
# @overload  get '/v0/containers/engine/:engine_name/state' 
# get engine state
# @return [String] engine state
get '/v0/containers/engine/:engine_name/state' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.read_state
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end
# @method get_engine_blueprint
# @overload  get '/v0/containers/engine/:engine_name/blueprint' 
# get engine blueprint
# @return [Hash] 
get '/v0/containers/engine/:engine_name/blueprint' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.load_blueprint
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end
# @method get_engine_build_report
# @overload   get '/v0/containers/engine/:engine_name/build_report'
# get engine build_report
# @return [String] 
get '/v0/containers/engine/:engine_name/build_report' do
  r = engines_api.get_build_report(params[:engine_name])
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r)
  end
end
