# @!group /containers/service/:service_name/consumers
# @method get_service_consumer
# @overload get '/v0/containers/service/:service_name/consumer/:parent_engine/:service_handle'
# return the details on the addressed consumer :service_name :parent_engine :service_handle
# @return [Hash]

get '/v0/containers/service/:service_name/consumer/:parent_engine/:service_handle' do
  begin
    service = get_service(params[:service_name])
    cparams = address_params(params, [:service_name, :service_handle, :parent_engine])
    r = service.registered_consumer(cparams)
    return_json(r)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end

# @!endgroup