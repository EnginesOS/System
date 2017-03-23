# @!group /containers/engine/:engine_name

# @method resolve_engine_template
# @overload post '/v0/containers/engine/:engine_name/template'
# Resolve Template string for engine :engine_name
# @param :template_string
# @return [String] :template_string with template macros resolved for this engine
post '/v0/containers/engine/:engine_name/template' do
  begin
    p_params = post_params(request)
    p_params[:engine_name] = params[:engine_name]
    engine = get_engine(params[:engine_name])
    return send_encoded_exception(request, engine, p_params) if engine.nil?
    cparams = assemble_params(p_params, [:engine_name], :template_string)
    resolved_string = engines_api.get_resolved_engine_string(cparams[:template_string], engine)
    return_text(resolved_string)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end
# @!endgroup
