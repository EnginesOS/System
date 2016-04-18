
  #/system/template/env P

post '/v0/containers/engine/:id/template' do
  engine = get_engine(params[:id])
  resolved_string = @@core_api.get_resolved_string(params['string'])
  return log_error('resolved_string', params) if resolved_string.is_a?(FalseClass)
  resolved_string.to_json
  
end