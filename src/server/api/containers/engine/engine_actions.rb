# @!group /containers/engine/:engine_name

# @method create_engine
# @overload get '/v0/containers/engine/:engine_name/create'
# create and start the engine from the engine image
# the local engine image is updated prior to the container creation
# @return [true]
# test cd /opt/engines/tests/engines_api/engine ; make create
get '/v0/containers/engine/:engine_name/create' do
  begin
    engine = get_engine(params[:engine_name])
    return_text(engine.create_container)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method recreate_engine
# @overload  get '/v0/containers/engine/:engine_name/recreate'
#  The engine must be stopped first.
# Recreate the engines container from the engine image and start the engine
#  The local engine image is updated prior to the container creation
# @return [true]
# test cd /opt/engines/tests/engines_api/engine ; make recreate
get '/v0/containers/engine/:engine_name/recreate' do
  begin
    # @return [true]
    # test cd /opt/engines/tests/engines_api/engine ; make 
    engine = get_engine(params[:engine_name])
    return_text(engine.recreate_container)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method stop_engine
# @overload get '/v0/containers/engine/:engine_name/stop'
# stop the engine
# @return [true]
# test cd /opt/engines/tests/engines_api/engine ; make stop
get '/v0/containers/engine/:engine_name/stop' do
  begin
    engine = get_engine(params[:engine_name])
    return_text(engine.stop_container)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method halt_engine
# @overload get '/v0/containers/engine/:engine_name/halt'
# halt the engine without affecting it's setstate
# @return [true]
# test cd /opt/engines/tests/engines_api/engine ; make halt
get '/v0/containers/engine/:engine_name/halt' do
  begin
    engine = get_engine(params[:engine_name])
    return_boolean(engine.halt_container)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method start_engine
# @overload get '/v0/containers/engine/:engine_name/start'
# start the engine
# @return [true]
# test cd /opt/engines/tests/engines_api/engine ; make start
get '/v0/containers/engine/:engine_name/start' do
  begin
    engine = get_engine(params[:engine_name])
    return_text(engine.start_container)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method restart_engine
# @overload get '/v0/containers/engine/:engine_name/restart'
# restart the engine
# @return [true]
# test cd /opt/engines/tests/engines_api/engine ; make start restart
get '/v0/containers/engine/:engine_name/restart' do
  begin
    engine = get_engine(params[:engine_name])
    return_text(engine.restart_container)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method pause_engine
# @overload get '/v0/containers/engine/:engine_name/pause'
# pause the engine
# @return [true]
# test cd /opt/engines/tests/engines_api/engine ; make pause 
get '/v0/containers/engine/:engine_name/pause' do
  begin
    engine = get_engine(params[:engine_name])
    return_text(engine.pause_container)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method unpause_engine
# @overload get '/v0/containers/engine/:engine_name/unpause'
# unpause the engine
# @return [true]
# test cd /opt/engines/tests/engines_api/engine ; make unpause
get '/v0/containers/engine/:engine_name/unpause' do
  begin
    engine = get_engine(params[:engine_name])
    return_text(engine.unpause_container)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method reinstall_engine
# @overload get '/v0/containers/engine/:engine_name/reinstall'
# reinstall the engine
# @return [true]
# test cd /opt/engines/tests/engines_api/engine ; make reinstall
get '/v0/containers/engine/:engine_name/reinstall' do
  begin
    engine = get_engine(params[:engine_name])
    return_text(engines_api.reinstall_engine(engine))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method destroy_engine
# @overload delete '/v0/containers/engine/:engine_name/destroy'
# destroy the engine container
# @return [true]
# test cd /opt/engines/tests/engines_api/engine ; make destroy
delete '/v0/containers/engine/:engine_name/destroy' do
  begin
    engine = get_engine(params[:engine_name])
    return_text(engine.destroy_container)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method delete_engine
# @overload delete '/v0/containers/engine/:engine_name/delete/:remove_data'
# delete the engine image
# @param remove_data all|none
# @return [true]
# test cd /opt/engines/tests/engines_api/engine ; make delete
delete '/v0/containers/engine/:engine_name/delete/*' do
  begin
    rparams = {}
    rparams[:engine_name] = params[:engine_name]
    # splats = params['splat']
    if params['splat'].nil? || params['splat'].count == 0
      rparams[:remove_all_data] = 'none'
    else
      rparams[:remove_all_data] = params['splat'][0]        
    end
    return_text(engines_api.delete_engine(rparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @!endgroup
