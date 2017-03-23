# @!group /containers/service/:service_name/template
# @method resolve_service_template
# @overload post '/v0/containers/service/:service_name/template'
# Resolve Template string
# @param :template_string
# @return [String] :template_string with template macros resolved for this service
post '/v0/containers/service/:service_name/template' do
  begin
    p_params = post_params(request)
    service = get_service(params[:service_name])
    cparams = assemble_params(p_params, :service_name, :template_string)
    resolved_string = engines_api.get_resolved_engine_string(cparams[:template_string], service)
    return_text(resolved_string)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @!endgroup
