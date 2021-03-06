# @!group /containers/engines/
# @method get_engines
# @overload  get '/v0/containers/engines/'
# @return [Array]  of Engines [Hash]
get '/v0/containers/engines/' do
  begin
    engines = engines_api.getManagedEngines
    managed_containers_to_json(engines)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method get_engines_container_name
# @overload get '/v0/containers/engines/container_name'
# returns an array of the container_name of configured engines
# @return [Array] of container_names [String]
#
get '/v0/containers/engines/container_name' do
  begin
    container_names = engines_api.list_managed_engines
    return_json_array(container_names)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method get_engines_status
# @overload get '/v0/containers/engines/status'
# returns a [container_name => engines_status,] of the container_name of configured engines
# @return [Array] Status Hash with keys :container_name values Hash with keys :state :set_state :progress_to :error
get '/v0/containers/engines/status' do
  begin
    return_json(engines_api.get_engines_status)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method get_engines_state
# @overload get '/v0/containers/engines/state'
# returns a [container_name => engines_state,] of the container_name of configured engines
# @return [Hash] States :container_name running|stopped|paused|nocontainer
get '/v0/containers/engines/state' do
  begin
    return_json(engines_api.get_engines_states)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method clear_lost_engines
# @overload get '/v0/containers/engines/clear_lost'
# removes an engine entry without a matching system config dir
# orphans persistent services
# returns a [] of the engines_names removed from the registry
# @return []
get '/v0/containers/engines/clear_lost' do
  begin
    return_json(engines_api.clear_lost_engines)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end

end
# @!endgroup
