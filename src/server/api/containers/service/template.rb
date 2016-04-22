#/containers/engine/container_name/template

post '/v0/containers/service/:service_name/template' do
  p params
  service = get_service(params[:service_name])
  cparams =  Utils::Params.assemble_params(params, :service_name,  :string) 
    p cparams
  resolved_string = @@core_api.get_resolved_engine_string(cparams[:string],service)
  return log_error('resolved_string', params) if resolved_string.is_a?(FalseClass)
  resolved_string.to_json
end

