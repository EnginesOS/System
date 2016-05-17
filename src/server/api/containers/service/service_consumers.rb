get '/v0/containers/service/:service_name/consumers/' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
    
  r = service.registered_consumers

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, service.last_error)
  end
end

get '/v0/containers/service/:service_name/consumers/:parent_engine' do

  service = get_service(params[:service_name])
 
  return log_error(request, service, params) if service.is_a?(EnginesError)

  cparams =  Utils::Params.address_params(params, [:service_name,:parent_engine])

  r = service.registered_consumers(cparams)

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, service.last_error)
  end
end

