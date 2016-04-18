#/containers/engine/container_name/template

post '/v0/system/template' do
  engine = get_engine(params[:id])
  resolved_string = @@core_api.get_resolved_string(params['string'],engine)
  return log_error('resolved_string', params) if resolved_string.is_a?(FalseClass)
  resolved_string.to_json
end