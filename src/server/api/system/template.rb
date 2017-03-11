# @!group /system/template

# @method resolve_template
# @overload post '/v0/system/template'
# Resolve Template string
# @param :template_string
# @return [String] :template_string with template macros resolved
post '/v0/system/template' do
  # engine = get_engine(params[:engine_name])
  params = post_params(request)
  cparams = assemble_params(params, [],  :string)
  return log_error(request, cparams, params) if cparams.is_a?(EnginesError)
  resolved_string = engines_api.get_resolved_string(cparams[:string])
  return log_error(request, resolved_string, cparams) if resolved_string.is_a?(EnginesError)
  status(202)
  content_type 'text/plain' 
  resolved_string.to_s
end
# @!endgroup