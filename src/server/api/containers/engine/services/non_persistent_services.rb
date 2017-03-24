# @!group /containers/engine/:engine_name/services/non_persistent/
# @method get_engine_non_persistent_services
# @overload get '/v0/containers/engine/:engine_name/services/non_persistent/'
# Return the non persistent services registered to the engine (which this engine consumes)
# @return [Array]
get '/v0/containers/engine/:engine_name/services/non_persistent/' do
  begin
    engine = get_engine(params[:engine_name])
    return_json_array(engines_api.list_non_persistent_services(engine))
  rescue StandardError => e
    return return_json_array(nil) if e.is_a?(EnginesException) && e.level == :warning
    send_encoded_exception(request: request, exception: e)
  end
end

# @method add_engine_non_persistent_service
# @overload post '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/:type_path/'
#  add non persistent services in the :publisher_namespace and :type_path registered to the engine with posted params
# post api_vars :variables
# @return [true|false]

post '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/*' do
  begin
    p_params = post_params(request)
    path_hash = engine_service_hash_from_params(params, true)
    p_params.merge!(path_hash)
    cparams = assemble_params(p_params, [:parent_engine, :publisher_namespace, :type_path], :all)
    return_text(engines_api.create_and_register_service(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method del_engine_non_persistent_service
# @overload delete '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/:type_path/:service_handle'
#  delete non persistent services sddressed by :publisher_namespace, :type_path :service_handle registered to the engine
# @return [true|false]

delete '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/*' do
  begin
    path_hash = engine_service_hash_from_params(params, false)
    cparams = assemble_params(path_hash, [:parent_engine, :publisher_namespace, :type_path, :service_handle], [])
    return_text(engines_api.dettach_service(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_engine_non_persistent_services_by_type
# @overload get '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/:type_path'
# Return the non persistent services matchedin the :publisher_namespace and :type_path registered to the engine (which this engine consumes)
# @return [Array]

get '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/*' do
  begin
    hash = engine_service_hash_from_params(params, true)
    return_json(engines_api.retrieve_engine_service_hashes(hash))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @!endgroup
