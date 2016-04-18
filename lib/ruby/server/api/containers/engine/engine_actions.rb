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
get '/v0/containers/engine/:id/create' do
  engine = get_engine(params[:id])
  r = engine.create_container
  unless r.is_a?(FalseClass)
    return r
  else
    return log_error('create')
  end
end

get '/v0/containers/engine/:id/recreate' do
  engine = get_engine(params[:id])
  r = engine.recreate_container
  unless r.is_a?(FalseClass)
    return r
  else
    return log_error('recreate')
  end
end

get '/v0/containers/engine/:id/stop' do
  engine = get_engine(params[:id])
  r = engine.stop_container
  unless r.is_a?(FalseClass)
    return r
  else
    return log_error('stop')
  end
end

get '/v0/containers/engine/:id/start' do
  engine = get_engine(params[:id])
  r = engine.start_container
  unless r.is_a?(FalseClass)
    return r
  else
    return log_error('start')
  end
end

get '/v0/containers/engine/:id/restart' do
  engine = get_engine(params[:id])
  r = engine.restart.is_a?(FalseClass)
  unless r
    return r
  else
    return log_error('restart')
  end
end

get '/v0/containers/engine/:id/pause' do
  engine = get_engine(params[:id])
  r = engine.pause_container
  unless r.is_a?(FalseClass)
    return r
  else
    return log_error('pause')
  end
end

get '/v0/containers/engine/:id/unpause' do
  engine = get_engine(params[:id])
  r = engine.unpause_container
  unless r.is_a?(FalseClass)
    return r
  else
    return log_error('unpause')
  end
end

get '/v0/containers/engine/:id/reinstall' do
  engine = get_engine(params[:id])
  r = @@core_api.reinstall_engine(engine)
  unless r.is_a?(FalseClass)
    return r
  else
    return log_error('reinstall')
  end
end

delete '/v0/containers/engine/:id/destroy' do
  engine = get_engine(params[:id])
  r = engine.destroy_container
  unless r.is_a?(FalseClass)
    return r
  else
    return log_error('destroy')
  end
end

delete '/v0/containers/engine/:id/delete_image' do
 r =  @@core_api.remove_engine(params[:id])

  unless r.is_a?(FalseClass)
    return r
  else
    return log_error('delete_image')
  end
  
  
end