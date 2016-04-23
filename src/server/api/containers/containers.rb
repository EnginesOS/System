#
#/containers/changed LIST
#/containers/name/network_metrics  ?
#
get '/v0/containers/changed/' do
  changed = @@engines_api.get_changed_containers
  unless changed.is_a?(FalseClass)
    return changed.to_json
  else
    return log_error('containers/changed')
  end
end

