#/containers/engine/container_name/template

post '/v0/containers/service/:service_name/template' do
  p params
  service = get_service(params[:service_name])
 return log_error(request, service, params) if service.is_a?(FalseClass)
  cparams =  Utils::Params.assemble_params(params, :service_name,  :string) 
    p cparams
  resolved_string = @@engines_api.get_resolved_engine_string(cparams[:string],service)
  return log_error(request, resolved_string, cparams) if resolved_string.is_a?(FalseClass)
  resolved_string.to_json
end

