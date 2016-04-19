
#
get '/v0/containers/service/:id/create' do
  service = get_service(params[:id])
  return false if service.is_a?(FalseClass)
  r = service.create_container
  return false if service.is_a?(FalseClass)
  unless r.is_a?(FalseClass)
    return r
  else
    return log_error('create')
  end
end

get '/v0/containers/service/:id/recreate' do
  service = get_service(params[:id])
  return false if service.is_a?(FalseClass)
  r = service.recreate_container
  unless r.is_a?(FalseClass)
    return r
  else
    return log_error('recreate')
  end
end

get '/v0/containers/service/:id/stop' do
  service = get_service(params[:id])
  return false if service.is_a?(FalseClass)
  r = service.stop_container
  unless r.is_a?(FalseClass)
    return r
  else
    return log_error('stop')
  end
end

get '/v0/containers/service/:id/start' do
  service = get_service(params[:id])
  return false if service.is_a?(FalseClass)
  r = service.start_container
  unless r.is_a?(FalseClass)
    return r
  else
    return log_error('start')
  end
end

get '/v0/containers/service/:id/restart' do
  service = get_service(params[:id])
  return false if service.is_a?(FalseClass)
  r = service.restart.is_a?(FalseClass)
  unless r
    return r
  else
    return log_error('restart')
  end
end

get '/v0/containers/service/:id/pause' do
  service = get_service(params[:id])
  return false if service.is_a?(FalseClass)
  r = service.pause_container
  unless r.is_a?(FalseClass)
    return r
  else
    return log_error('pause')
  end
end

get '/v0/containers/service/:id/unpause' do
  service = get_service(params[:id])
  return false if service.is_a?(FalseClass)
  r = service.unpause_container
  unless r.is_a?(FalseClass)
    return r
  else
    return log_error('unpause')
  end
end



delete '/v0/containers/service/:id/destroy' do
  service = get_service(params[:id])
  return false if service.is_a?(FalseClass)
  r = service.destroy_container
  unless r.is_a?(FalseClass)
    return r
  else
    return log_error('destroy')
  end
end

delete '/v0/containers/service/:id/delete' do
  r =  @@core_api.remove_service(params[:id])
  unless r.is_a?(FalseClass)
    return r
  else
    return log_error('delete_image')
  end

end