#/containers/engines/state

#/containers/engines/container_name
#/containers/engines/
#/containers/engine/container_name/build_report
#/containers/engine/container_name/blueprint

get '/v0/containers/service/:service_name' do
  service = get_service(params[:service_name])
  unless service.is_a?(FalseClass)
    return service.to_json
  else
    return log_error(request)
  end
end

get '/v0/containers/service/:service_name/state' do
  service = get_service(params[:service_name])
 return false if service.is_a?(FalseClass)
  r = service.read_state
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request)
  end
end


