# @method resolve_engine_template
# @overload post '/v0/containers/engine/:engine_name/template'
# Resolve Template string :string for engine :engine_name
# @return [String]
post '/v0/containers/engine/:engine_name/template' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  cparams =  Utils::Params.assemble_params(params, [:engine_name], :string)
  resolved_string = engines_api.get_resolved_engine_string(cparams[:string],engine)
  return log_error(request, resolved_string, cparams) if resolved_string.is_a?(EnginesError)
  resolved_string.to_json
end