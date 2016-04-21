#/containers/engine/container_name/template

post '/v0/containers/service/:service_name/template' do
  service = get_service(params[:service_name])
  cparams =  assemble_params(params, [:service_name],  [:string]) 
  resolved_string = @@core_api.get_resolved_engine_string(cparams[:string],service)
  return log_error('resolved_string', params) if resolved_string.is_a?(FalseClass)
  resolved_string.to_json
end

