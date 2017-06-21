# @!group /service_manager/
# @method get_service_definitions
# @overload get '/v0/service_manager/service_definitions/:publisher_namespace/:type_path'
# return  Hash for service definition addressed by
#  :publisher_namespace :type_path
# @return [Hash]
get '/v0/service_manager/service_definitions/:publisher_namespace/*' do
  begin
    params[:type_path] = params['splat'][0]
    cparams = assemble_params(params, [:publisher_namespace, :type_path], [])
      STDERR.puts('params ' + params.to_s + ' cparams ' + cparams.to_s)
  return_json(engines_api.get_service_definition(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @!endgroup
