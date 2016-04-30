
#
get '/v0/containers/service/:service_name/create' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(FalseClass)
  r = service.create_container
 
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r, service.last_error)
  end
end

get '/v0/containers/service/:service_name/recreate' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(FalseClass)
  r = service.recreate_container
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r, service.last_error)
  end
end

get '/v0/containers/service/:service_name/stop' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(FalseClass)
  r = service.stop_container
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r, service.last_error)
  end
end

get '/v0/containers/service/:service_name/start' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(FalseClass)
  r = service.start_container
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r, service.last_error)
  end
end

get '/v0/containers/service/:service_name/restart' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(FalseClass)
  r = service.restart_container.is_a?(FalseClass)
  unless r
    return r.to_json
  else
    return log_error(request, r, service.last_error)
  end
end

get '/v0/containers/service/:service_name/pause' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(FalseClass)
  r = service.pause_container
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r, service.last_error)
  end
end

get '/v0/containers/service/:service_name/unpause' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(FalseClass)
  r = service.unpause_container
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r, service.last_error)
  end
end



delete '/v0/containers/service/:service_name/destroy' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(FalseClass)
  r = service.destroy_container
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r, service.last_error)
  end
end

delete '/v0/containers/service/:service_name/delete' do
  r =  @@engines_api.remove_service(params[:service_name])
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, r)
  end

end