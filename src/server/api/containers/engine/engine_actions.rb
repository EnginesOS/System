#/containers/engine/container_name
#/containers/engine/container_name/recreate
#/containers/engine/container_name/stop
#/containers/engine/container_name/start
#/containers/engine/container_name/pause
#/containers/engine/container_name/unpause
#/containers/engine/container_name/destroy
#/containers/engine/container_name/delete_image
#/containers/engine/container_name/reinstall
#/containers/engine/container_name/create
#/containers/engine/container_name/restart
#
get '/v0/containers/engine/:engine_name/create' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(FalseClass)
  r = engine.create_container
  return log_error(request, engine, params) if engine.is_a?(FalseClass)
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r)
  end
end

get '/v0/containers/engine/:engine_name/recreate' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(FalseClass)
  r = engine.recreate_container
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end

get '/v0/containers/engine/:engine_name/stop' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(FalseClass)
  r = engine.stop_container
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end

get '/v0/containers/engine/:engine_name/start' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(FalseClass)
  r = engine.start_container
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end

get '/v0/containers/engine/:engine_name/restart' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(FalseClass)
  r = engine.restart_container.is_a?(FalseClass)
  unless r
    return r.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end

get '/v0/containers/engine/:engine_name/pause' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(FalseClass)
  r = engine.pause_container
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end

get '/v0/containers/engine/:engine_name/unpause' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(FalseClass)
  r = engine.unpause_container
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end

get '/v0/containers/engine/:engine_name/reinstall' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(FalseClass)
  r = @@engines_api.reinstall_engine(engine)
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r)
  end
end

delete '/v0/containers/engine/:engine_name/destroy' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(FalseClass)
  r = engine.destroy_container
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r,  engine.last_error)
  end
end

delete '/v0/containers/engine/:engine_name/delete' do
  r =  @@engines_api.remove_engine(params[:engine_name])

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r, 'delete_image')
  end

end