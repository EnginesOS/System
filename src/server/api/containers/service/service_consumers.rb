# @!group /containers/service/:service_name/consumers
# @method get_service_consumers
# @overload get  '/v0/containers/service/:service_name/consumers/'
# return the consumers of :service_name
# @return [Array]

get '/v0/containers/service/:service_name/consumers/' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  r = service.registered_consumers
  return log_error(request, r, service.last_error) if r.is_a?(EnginesError)
  return_json_array(r)
end

# @method get_service_consumers_for_engine
# @overload get  '/v0/containers/service/:service_name/consumers/:parent_engine'
# return the services on :service_name consumbe by :parent_engine
# @return [Array]

get '/v0/containers/service/:service_name/consumers/:parent_engine' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  cparams = address_params(params, [:service_name,:parent_engine])

  r = service.registered_consumers(cparams)
  return log_error(request, r, service.last_error) if r.is_a?(EnginesError)
  return_json_array(r)
end

# @!endgroup