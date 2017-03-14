
# @!group /containers/services


# @method get_services
# @overload  get '/v0/containers/services/'
# @return [Array] services [Hash]
get '/v0/containers/services/' do
  engines = engines_api.getManagedServices
  return log_error(request,engines ) if engines.is_a?(EnginesError)
   managed_containers_to_json(engines)
end

#
# @method get_services_container_name
# @overload get '/v0/containers/services/container_name'
# @return [Array] service container_names
#
get '/v0/containers/services/container_name' do
  container_names = engines_api.list_managed_services
  return log_error(request, container_names) if container_names.is_a?(EnginesError)
  return_json_array(container_names)
end

# @method get_services_state
# @overload get '/v0/containers/services/state'
#  service_state running|stopped|paused|nocontainer
# @return [Hash] [container_name => service_state]

get '/v0/containers/services/state' do
  states = engines_api.get_services_states
  return log_error(request, states) if states.is_a?(EnginesError)
  return_json(states)
end
# @method get_services_status
# @overload get '/v0/containers/services/status'
# returns a [container_name => service_status,] of the container_name of configured services
# @return  [Hash] [:container_name => service_status] service_status Hash :state :set_state :progress_to :error
get '/v0/containers/services/status' do
  status = engines_api.get_services_status
  return log_error(request, statuses) if status.is_a?(EnginesError)
  return_json(status)
end
# @method get_system_services
# @overload  get '/v0/containers/services/system'
# returns a Json array of the system services
# @return [Array] system services
get '/v0/containers/services/system' do
  states = engines_api.list_system_services
  return log_error(request, states) if states.is_a?(EnginesError)
  return_json_array(states)
end
# @!endgroup