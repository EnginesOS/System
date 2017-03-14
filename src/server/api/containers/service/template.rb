# @!group /containers/service/:service_name/template
# @method resolve_service_template
# @overload post '/v0/containers/service/:service_name/template'
# Resolve Template string
# @param :template_string
# @return [String] :template_string with template macros resolved for this service
post '/v0/containers/service/:service_name/template' do
  p_params = post_params(request)
  service = get_service(params[:service_name])
  return log_error(request, service,   p_params) if service.is_a?(EnginesError)
  cparams = assemble_params(  p_params, :service_name,  :template_string)
  return log_error(request, cparams, p_params) if cparams.is_a?(EnginesError)
  resolved_string = engines_api.get_resolved_engine_string(cparams[:template_string],service)
  return log_error(request, resolved_string, cparams) if resolved_string.is_a?(EnginesError)
  return_text(resolved_string)
end

# @!endgroup