# @!group /containers/services

# @method get_services
# @overload  get '/v0/containers/services/'
# @return [Array] services [Hash]
get '/v0/containers/services/' do
  begin
    engines = engines_api.getManagedServices
    managed_containers_to_json(engines)
  rescue StandardError => e
    send_encoded_exception(request, e)
#    send_encoded_exception(request: request, exception: e , status: 404)
  end
end

#
# @method get_services_container_name
# @overload get '/v0/containers/services/container_name'
# @return [Array] service container_names
#
get '/v0/containers/services/container_name' do
  begin
    container_names = engines_api.list_managed_services
    return_json_array(container_names)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end

# @method get_services_state
# @overload get '/v0/containers/services/state'
#  service_state running|stopped|paused|nocontainer
# @return [Hash] [container_name => service_state]

get '/v0/containers/services/state' do
  begin
    states = engines_api.get_services_states
    return_json(states)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end
# @method get_services_status
# @overload get '/v0/containers/services/status'
# returns a [container_name => service_status,] of the container_name of configured services
# @return  [Hash] [:container_name => service_status] service_status Hash :state :set_state :progress_to :error
get '/v0/containers/services/status' do
  begin
    status = engines_api.get_services_status
    return_json(status)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end
# @method get_system_services
# @overload  get '/v0/containers/services/system'
# returns a Json array of the system services
# @return [Array] system services
get '/v0/containers/services/system' do
  begin
    states = engines_api.list_system_services
    return_json_array(states)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end
# @!endgroup
