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
    return_text(engines_api.get_resolved_string(cparams[:string]))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
