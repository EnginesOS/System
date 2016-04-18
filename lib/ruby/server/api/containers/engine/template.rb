#/containers/engine/container_name/template

post '/v0/containers/engine/:id/template' do
  engine = get_engine(params[:id])
  resolved_string = @@core_api.get_resolved_engine_string(params[:string],engine)
  return log_error('resolved_string', params) if resolved_string.is_a?(FalseClass)
  resolved_string.to_json
end