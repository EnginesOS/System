# @!group /system/template

# @method resolve_template
# @overload post '/v0/system/template'
# Resolve Template string
# @param :template_string
# @return [String] :template_string with template macros resolved
post '/v0/system/template' do
  begin
    params = post_params(request)
    cparams = assemble_params(params, [], :string)
    resolved_string = engines_api.get_resolved_string(cparams[:string])
    return_text(resolved_string)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end
# @!endgroup
