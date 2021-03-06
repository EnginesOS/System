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
    cparams = assemble_params(p_params,[], :template_string)
    return_text(engines_api.get_resolved_engine_string(cparams[:template_string], service))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
