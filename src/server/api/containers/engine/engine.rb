
# @!group /containers/engine/:engine_name

# @method get_engine
# @overload get '/v0/containers/engine/:engine_name' 
# get engine
# @return [Hash]
get '/v0/containers/engine/:engine_name' do
  engine = get_engine(params[:engine_name])
  return log_error(request,engine, params[:engine_name]) if engine.is_a?(EnginesError)
  managed_container_as_json(engine)
end

# @method get_engine_status
# @overload get '/v0/containers/engine/:engine_name/status' 
# get engine status
# @return [Hash] :state :set_state :progress_to :error
get '/v0/containers/engine/:engine_name/status' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.status
  return log_error(request, r, engine.last_error) if r.is_a?(EnginesError)
  r.to_json
end
# @method get_engine_state
# @overload  get '/v0/containers/engine/:engine_name/state' 
# get engine state
# @return [String] engine state
get '/v0/containers/engine/:engine_name/state' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.read_state
  return log_error(request, r, engine.last_error) if r.is_a?(EnginesError)
    content_type 'text/plain' 
  r.to_s  
end
# @method get_engine_blueprint
# @overload  get '/v0/containers/engine/:engine_name/blueprint' 
# get engine blueprint
# @return [Hash] 
get '/v0/containers/engine/:engine_name/blueprint' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.load_blueprint
  return log_error(request, r, engine.last_error) if r.is_a?(EnginesError)
   r.to_json
end
# @method get_engine_build_report
# @overload   get '/v0/containers/engine/:engine_name/build_report'
# get engine build_report
# @return [String] 
get '/v0/containers/engine/:engine_name/build_report' do
  r = engines_api.get_build_report(params[:engine_name])
  return log_error(request, r) if r.is_a?(EnginesError)
  content_type 'text/plain' 
    r.to_s
end
# @method get_engine_websites
# @overload   get '/v0/containers/engine/:engine_name/websites'
# get engine websites
# @return [String] 
get '/v0/containers/engine/:engine_name/websites' do
  engine = get_engine(params[:engine_name])
   return log_error(request, engine, params) if engine.is_a?(EnginesError)
   r = engine.web_sites
  return log_error(request, r) if r.is_a?(EnginesError)
  r.to_json
end
# @method get_engine_logs
# @overload   get '/v0/containers/engine/:engine_name/logs'
# get engine logs
# @return [String] 
get '/v0/containers/engine/:engine_name/logs' do
  engine = get_engine(params[:engine_name])
   return log_error(request, engine, params) if engine.is_a?(EnginesError)
   r = engine.logs_container()
  return log_error(request, r) if r.is_a?(EnginesError)
  r.force_encoding(Encoding::UTF-8)
    return r.to_json
end