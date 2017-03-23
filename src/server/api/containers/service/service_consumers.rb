# @!group /containers/service/:service_name/consumers
# @method get_service_consumers
# @overload get  '/v0/containers/service/:service_name/consumers/'
# return the consumers of :service_name
# @return [Array]

get '/v0/containers/service/:service_name/consumers/' do
  begin
    service = get_service(params[:service_name])
    r = service.registered_consumers
    return_json_array(r)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end

# @method get_service_consumers_for_engine
# @overload get  '/v0/containers/service/:service_name/consumers/:parent_engine'
# return the services on :service_name consumbe by :parent_engine
# @return [Array]

get '/v0/containers/service/:service_name/consumers/:parent_engine' do
  begin
    service = get_service(params[:service_name])
    cparams = address_params(params, [:service_name, :parent_engine])
    r = service.registered_consumers(cparams)
    return_json_array(r)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end

# @!endgroup