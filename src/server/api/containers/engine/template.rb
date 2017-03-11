# @!group /containers/engine/:engine_name

# @method resolve_engine_template
# @overload post '/v0/containers/engine/:engine_name/template'
# Resolve Template string for engine :engine_name
# @param :template_string 
# @return [String] :template_string with template macros resolved for this engine
post '/v0/containers/engine/:engine_name/template' do
  p_params = post_params(request)
  p_params[:engine_name] = params[:engine_name]
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, p_params) if engine.is_a?(EnginesError)
  cparams =  Utils::Params.assemble_params(p_params, [:engine_name], :template_string)
  return log_error(request, cparams, p_params) if cparams.is_a?(EnginesError)
  resolved_string = engines_api.get_resolved_engine_string(cparams[:template_string],engine)
  return log_error(request, resolved_string, cparams) if resolved_string.is_a?(EnginesError)
  return_text(r)
end
# @!endgroup