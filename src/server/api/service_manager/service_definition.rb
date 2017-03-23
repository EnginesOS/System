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
    r = engines_api.get_service_definition(cparams)
    return_json(r)
  rescue StandardError => e
    log_error(request, e)
  end
end

# @!endgroup
