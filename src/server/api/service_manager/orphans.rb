# @!group /service_manager/orphan_services/

# @method orphan_lost_services
# @overload get '/v0/service_manager/orphan_lost_services'
# @return [Array] orphan_lost_services
get '/v0/service_manager/orphan_lost_services' do
  begin
    return_json(engines_api.orphan_lost_services)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_all_orphan_services
# @overload get '/v0/service_manager/orphan_services/'
# @return [Array] Orphan Service Hashes
get '/v0/service_manager/orphan_services/' do
  begin
    return_json(engines_api.orphaned_services_registry)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method get_orphan_services_by_type
# @overload get '/v0/service_manager/orphan_services/:publisher_namespace/:type_path:'
# @return [Array] Orphan Service Hashes
get '/v0/service_manager/orphan_services/:publisher_namespace/*' do
  begin
    params[:type_path] = params['splat'][0] if params.key?('splat') && params['splat'].is_a?(Array)
    cparams = assemble_params(params, [:publisher_namespace, :type_path], [])
    return_json_array(engines_api.orphaned_services(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method get_orphan_service
# @overload get '/v0/service_manager/orphan_service/:publisher_namespace/:type_path:/:parent_engine/:service_handle'
# @return [Hash] Orphan Service Hash
get '/v0/service_manager/orphan_service/:publisher_namespace/*' do
  begin
    tp_plus = File.dirname(params['splat'][0])
    params[:service_handle] = File.basename(tp_plus)
    tp_plus = File.dirname(tp_plus)
    params[:parent_engine] = File.basename(tp_plus)
    params[:type_path] = File.dirname(tp_plus)
    cparams = assemble_params(params, [:publisher_namespace, :type_path, :service_handle, :parent_engine], [])
    return_json(engines_api.retrieve_orphan(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method delete_orphan_service
# @overload delete '/v0/service_manager/orphan_service/:publisher_namespace/:type_path:/:parent_engine/:service_handle'
# remove underlying data and delete orphan
# @return [true]
delete '/v0/service_manager/orphan_service/:publisher_namespace/*' do
  begin
    tp_plus = File.dirname(params['splat'][0])
    params[:service_handle] = File.basename(tp_plus)
    tp_plus = File.dirname(tp_plus)
    params[:parent_engine] = File.basename(tp_plus)
    params[:type_path] = File.dirname(tp_plus)
    cparams = assemble_params(params, [:publisher_namespace, :type_path, :parent_engine, :service_handle], [])
    service_hash = engines_api.retrieve_orphan(cparams)
    return_text(engines_api.remove_orphaned_service(service_hash))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
