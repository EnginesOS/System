#/containers/engine/container_name/template

post '/v0/containers/service/:id/template/string' do
  service = get_service(params[:id])
  resolved_string = @@core_api.get_resolved_engine_string(params[:string],service)
  return log_error('resolved_string', params) if resolved_string.is_a?(FalseClass)
  resolved_string.to_json
end

post '/v0/containers/service/:id/template/service' do
  service = get_service(params[:id])
  resolved_string = @@core_api.get_resolved_service_hash(Utils.symbolize_keys(params),service)
  return log_error('resolved_string', params) if resolved_string.is_a?(FalseClass)
  resolved_string.to_json
end