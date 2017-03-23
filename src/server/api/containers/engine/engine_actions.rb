# @!group /containers/engine/:engine_name
# @method create_engine
# @overload get '/v0/containers/engine/:engine_name/create'
# create and start the engine from the engine image
# the local engine image is updated prior to the container creation
# @return [true]
get '/v0/containers/engine/:engine_name/create' do
  begin
    engine = get_engine(params[:engine_name])
    return log_error(request, engine, params) if engine.nil?
    r = engine.create_container
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end

# @method recreate_engine
# @overload  get '/v0/containers/engine/:engine_name/recreate'
#  The engine must be stopped first.
# Recreate the engines container from the engine image and start the engine
#  The local engine image is updated prior to the container creation
# @return [true]
get '/v0/containers/engine/:engine_name/recreate' do
  begin
    engine = get_engine(params[:engine_name])
    return log_error(request, engine, params) if engine.nil?
    r = engine.recreate_container
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method stop_engine
# @overload get '/v0/containers/engine/:engine_name/stop'
# stop the engine
# @return [true]
get '/v0/containers/engine/:engine_name/stop' do
  begin
    engine = get_engine(params[:engine_name])
    return log_error(request, engine, params) if engine.nil?
    r = engine.stop_container
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method halt_engine
# @overload get '/v0/containers/engine/:engine_name/halt'
# halt the engine without affecting it's setstate
# @return [true]
get '/v0/containers/engine/:engine_name/halt' do
  begin
    engine = get_engine(params[:engine_name])
    return log_error(request, engine, params) if engine.nil?
    r = engine.halt_container
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method start_engine
# @overload get '/v0/containers/engine/:engine_name/start'
# start the engine
# @return [true]
get '/v0/containers/engine/:engine_name/start' do
  begin
    engine = get_engine(params[:engine_name])
    return log_error(request, engine, params) if engine.nil?
    r = engine.start_container
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method restart_engine
# @overload get '/v0/containers/engine/:engine_name/restart'
# restart the engine
# @return [true]
get '/v0/containers/engine/:engine_name/restart' do
  begin
    engine = get_engine(params[:engine_name])
    return log_error(request, engine, params) if engine.nil?
    r = engine.restart_container
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method pause_engine
# @overload get '/v0/containers/engine/:engine_name/pause'
# pause the engine
# @return [true]
get '/v0/containers/engine/:engine_name/pause' do
  begin
    engine = get_engine(params[:engine_name])
    return log_error(request, engine, params) if engine.nil?
    r = engine.pause_container
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method unpause_engine
# @overload get '/v0/containers/engine/:engine_name/unpause'
# unpause the engine
# @return [true]
get '/v0/containers/engine/:engine_name/unpause' do
  begin
    engine = get_engine(params[:engine_name])
    return log_error(request, engine, params) if engine.nil?
    r = engine.unpause_container
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end

# @method reinstall_engine
# @overload get '/v0/containers/engine/:engine_name/reinstall'
# reinstall the engine
# @return [true]
get '/v0/containers/engine/:engine_name/reinstall' do
  begin
    engine = get_engine(params[:engine_name])
    return log_error(request, engine, params) if engine.nil?
    r = engines_api.reinstall_engine(engine)
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end

# @method destroy_engine
# @overload delete '/v0/containers/engine/:engine_name/destroy'
# destroy the engine container
# @return [true]
delete '/v0/containers/engine/:engine_name/destroy' do
  begin
    engine = get_engine(params[:engine_name])
    return log_error(request, engine, params) if engine.nil?
    r = engine.destroy_container
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method delete_engine
# @overload delete '/v0/containers/engine/:engine_name/delete/:remove_data'
# delete the engine image
# @param remove_data all|none
# @return [true]
delete '/v0/containers/engine/:engine_name/delete/*' do
  begin
    rparams = {}
    rparams[:engine_name] = params[:engine_name]
    # splats = params['splat']
    if params['splat'].nil? || params['splat'].count == 0
      rparams[:remove_all_data] = false
    else
      rparams[:remove_all_data] = true if params['splat'][0] == 'all'
      rparams[:remove_all_data] = false if params['splat'][0] == 'none'
    end
    r = engines_api.delete_engine(rparams)
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end

# @!endgroup
