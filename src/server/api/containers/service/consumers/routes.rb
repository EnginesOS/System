get '/v0/containers/service/:service_name/consumers/:parent_engine' do
  service = get_service(params[:service_name])
    return false if service.is_a?(FalseClass)
  cparams =  Utils::Params.address_params(params, [:service_name,:parent_engine])
  r = service.registered_consumer(cparams)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, service.last_error)
  end
end

get '/v0/containers/service/:service_name/consumers/' do
  service = get_service(params[:service_name])
    return false if service.is_a?(FalseClass)
    
  r = service.registered_consumers

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request, service.last_error)
  end
end
