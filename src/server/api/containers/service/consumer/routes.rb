


get '/v0/containers/service/:service_name/consumer/:parent_engine/:service_handle' do
  service = get_service(params[:service_name])
    return false if service.is_a?(FalseClass)
    p :params
    p params
 cparams =  Utils::Params.address_params(params, [:service_name,:service_handle,:parent_engine])
   p cparams
  r = service.registered_consumer(cparams)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error('consumers')
  end
end