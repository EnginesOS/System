
# @!group /containers/service/:service_name/consumers
# @method get_service_consumer
# @overload get '/v0/containers/service/:service_name/consumer/:parent_engine/:service_handle'
# return the details on the addressed consumer :service_name :parent_engine :service_handle 
# @return [Hash|EnginesError]

get '/v0/containers/service/:service_name/consumer/:parent_engine/:service_handle' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
 cparams =  Utils::Params.address_params(params, [:service_name,:service_handle,:parent_engine])
  r = service.registered_consumer(cparams)

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, service.last_error)
  end
end

# @!endgroup