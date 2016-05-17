
# @!group Service
# @method resolve_service_template
# @overload post '/v0/containers/service/:service_name/template'
# Resolve Template string  for params
#  :template_string 
# for service :service_name
# @return [String]
post '/v0/containers/service/:service_name/template' do
  p params
  service = get_service(params[:service_name])
 return log_error(request, service, params) if service.is_a?(EnginesError)
  cparams =  Utils::Params.assemble_params(params, :service_name,  :template_string) 
    p cparams
  resolved_string = engines_api.get_resolved_engine_string(cparams[:template_string],service)
  return log_error(request, resolved_string, cparams) if resolved_string.is_a?(EnginesError)
  resolved_string.to_json
end

