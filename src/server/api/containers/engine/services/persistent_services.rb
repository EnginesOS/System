# @!group /containers/engine/:engine_name/services/persistent/
# @method get_engine_persistent_services
# @overload get '/v0/containers/engine/:engine_name/services/persistent/'
# Return the persistent services registered to the engine (which this engine consumes)
# @return [Array]
get '/v0/containers/engine/:engine_name/services/persistent/' do
  begin
    engine = get_engine(params[:engine_name])
    return_json_array(engines_api.list_persistent_services(engine))
  rescue StandardError => e
    unless e.is_a?(EnginesException) && e.level == :warning
      send_encoded_exception(request: request, exception: e)
    else
      return_json_array(nil)
    end
  end
end

# @method get_engine_persistent_services_by_type
# @overload get '/v0/containers/engine/:engine_name/services/persistent/:publisher_namespace/:type_path'
# Return the persistent services matchedin the :publisher_namespace and :type_path registered to the engine (which this engine consumes)
# @return [Array]

get '/v0/containers/engine/:engine_name/services/persistent/:publisher_namespace/*' do
  begin
    hash = engine_service_hash_from_params(params, true)
    r = engines_api.retrieve_engine_service_hashes(hash)
    return_json_array(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method add_engine_persistent_share_service
# @overload post '/v0/containers/engine/:engine_name/services/persistent/share/:owner/:publisher_namespace/:type_path/:service_handle'
#  add persistent services in the :publisher_namespace and :type_path  :service_handle registered to the engine with posted params
# post api_vars :variables
# @return [true|false]

post '/v0/containers/engine/:engine_name/services/persistent/share/:owner/:publisher_namespace/*' do
  begin
    p_params = post_params(request)
    path_hash = engine_service_hash_from_params(params, false)
    path_hash[:owner] = params[:owner]
    p_params.merge!(path_hash)
    cparams = assemble_params(p_params, [:parent_engine, :owner, :publisher_namespace, :type_path, :service_handle], :all)
    return_text(engines_api.connect_share_service(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method add_engine_persistent_orphan_service
# @overload post '/v0/containers/engine/:engine_name/services/persistent/orphan/:owner/:publisher_namespace/:type_path/:service_handle'
#  add persistent services in the :publisher_namespace and :type_path  :service_handle registered to the engine with posted params
# post api_vars :variables
# @return [true|false]

post '/v0/containers/engine/:engine_name/services/persistent/orphan/:owner/:publisher_namespace/*' do
  begin
    p_params = post_params(request)
    path_hash = engine_service_hash_from_params(params, false)
    path_hash[:owner] = params[:owner]
    p_params.merge!(path_hash)
    cparams = assemble_params(p_params, [:parent_engine, :owner, :publisher_namespace, :type_path, :service_handle], :all)
    return_text(engines_api.connect_orphan_service(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method add_engine_persistent_service
# @overload post '/v0/containers/engine/:engine_name/services/persistent/:publisher_namespace/:type_path'
#  add persistent service in the :publisher_namespace and :type_path  the engine with posted params
# post api_vars :variables
# @return [true|false]

post '/v0/containers/engine/:engine_name/services/persistent/:publisher_namespace/*' do
  begin
    p_params = post_params(request)
    path_hash = engine_service_hash_from_params(params, true)
    p_params.merge!(path_hash)
    cparams = assemble_params(p_params, [:parent_engine, :publisher_namespace, :type_path], :all)
    return_text(engines_api.create_and_register_persistent_service(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method del_engine_persistent_service
# @overload delete '/v0/containers/engine/:engine_name/services/persistent/:remove_all_data/:publisher_namespace/:type_path/:service_handle'
#  delete non persistent services sddressed by :publisher_namespace, :type_path :service_handle registered to the engine
# @return [true|false]
# :remove_all_data all|none
# none orphanicates the persistent services
delete '/v0/containers/engine/:engine_name/services/persistent/:remove_all_data/:publisher_namespace/*' do
  begin
    path_hash = engine_service_hash_from_params(params, false)
    cparams = assemble_params(path_hash, [:parent_engine, :publisher_namespace, :type_path, :service_handle, :remove_all_data], [])
    return_text(engines_api.remove_persistent_service(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method del_engine_persistent_service_share
# @overload delete '/v0/containers/engine/:engine_name/services/persistent/shared/:parent_engine/:publisher_namespace/:type_path/:service_handle'
# removes the share from the engine
# @return [true|false]
delete '/v0/containers/engine/:engine_name/services/persistent/shared/:owner/:publisher_namespace/*' do
  begin
    path_hash = engine_service_hash_from_params(params, false)
    cparams = assemble_params(path_hash, [:engine_name, :owner, :publisher_namespace, :type_path, :service_handle], [])
    return_text(engines_api.dettach_share_service(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
