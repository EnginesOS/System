# @!group /containers/engine/:engine_name
# @method create_engine
# @overload get '/v0/containers/engine/:engine_name/create'
# create and start the engine from the engine image
# the local engine image is updated prior to the container creation
# @return [true]
get '/v0/containers/engine/:engine_name/create' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.create_container
  return log_error(request, r) if r.is_a?(EnginesError)
  return_text(r)
end

# @method recreate_engine
# @overload  get '/v0/containers/engine/:engine_name/recreate'
#  The engine must be stopped first.
# Recreate the engines container from the engine image and start the engine
#  The local engine image is updated prior to the container creation
# @return [true]
get '/v0/containers/engine/:engine_name/recreate' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.recreate_container
  return log_error(request, r, engine.last_error) if r.is_a?(EnginesError)
  return_text(r)
end
# @method stop_engine
# @overload get '/v0/containers/engine/:engine_name/stop'
# stop the engine
# @return [true]
get '/v0/containers/engine/:engine_name/stop' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.stop_container
  return log_error(request, r, engine.last_error) if r.is_a?(EnginesError)
  return_text(r)
end
# @method halt_engine
# @overload get '/v0/containers/engine/:engine_name/halt'
# halt the engine without affecting it's setstate
# @return [true]
get '/v0/containers/engine/:engine_name/halt' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.halt_container
  return log_error(request, r, engine.last_error) if r.is_a?(EnginesError)
  return_text(r)
end
# @method start_engine
# @overload get '/v0/containers/engine/:engine_name/start'
# start the engine
# @return [true]
get '/v0/containers/engine/:engine_name/start' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.start_container
  return log_error(request, r, engine.last_error) if r.is_a?(EnginesError)
  return_text(r)
end
# @method restart_engine
# @overload get '/v0/containers/engine/:engine_name/restart'
# restart the engine
# @return [true]
get '/v0/containers/engine/:engine_name/restart' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.restart_container
  return log_error(request, r, engine.last_error) if r.is_a?(EnginesError)
  return_text(r)
end
# @method pause_engine
# @overload get '/v0/containers/engine/:engine_name/pause'
# pause the engine
# @return [true]
get '/v0/containers/engine/:engine_name/pause' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.pause_container
  return log_error(request, r, engine.last_error) if r.is_a?(EnginesError)
  return_text(r)
end
# @method unpause_engine
# @overload get '/v0/containers/engine/:engine_name/unpause'
# unpause the engine
# @return [true]
get '/v0/containers/engine/:engine_name/unpause' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.unpause_container
  return log_error(request, r, engine.last_error) if r.is_a?(EnginesError)
  return_text(r)
end

# @method reinstall_engine
# @overload get '/v0/containers/engine/:engine_name/reinstall'
# reinstall the engine
# @return [true]
get '/v0/containers/engine/:engine_name/reinstall' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engines_api.reinstall_engine(engine)
  return log_error(request, r) if r.is_a?(EnginesError)
  return_text(r)
end

# @method destroy_engine
# @overload delete '/v0/containers/engine/:engine_name/destroy'
# destroy the engine container
# @return [true]
delete '/v0/containers/engine/:engine_name/destroy' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.destroy_container
  return log_error(request, r,  engine.last_error) if r.is_a?(EnginesError)
  return_text(r)
end
# @method delete_engine
# @overload delete '/v0/containers/engine/:engine_name/delete/:remove_data'
# delete the engine image
# @param remove_data all|none
# @return [true]
delete '/v0/containers/engine/:engine_name/delete/*' do

  rparams = {}
  rparams[:engine_name] = params[:engine_name]
 # splats = params['splat']
  unless params['splat'].nil? || params['splat'].count == 0
    rparams[:remove_all_data] = true  if params['splat'][0] == 'all'
    rparams[:remove_all_data] = false  if params['splat'][0] == 'none'
  else
    rparams[:remove_all_data] = false
  end
  r =  engines_api.delete_engine(rparams)
  return log_error(request, r, 'delete_image') if r.is_a?(EnginesError)
return_text(r)
end

# @!endgroup