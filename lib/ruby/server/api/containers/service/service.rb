#/containers/engines/state

#/containers/engines/container_name
#/containers/engines/
#/containers/engine/container_name/build_report
#/containers/engine/container_name/blueprint

get '/v0/containers/service/:id' do
  service = get_service(params[:id])
  unless service.is_a?(FalseClass)
    return service.to_json
  else
    return log_error('service')
  end
end

get '/v0/containers/service/:id/state' do
  service = get_service(params[:id])
 return false if service.is_a?(FalseClass)
  r = service.read_state
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error('engine')
  end
end


