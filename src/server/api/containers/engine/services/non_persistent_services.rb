
# @!group /containers/engine/:engine_name/services/non_persistent/
# @method get_engine_non_persistent_services
# @overload get '/v0/containers/engine/:engine_name/services/non_persistent/'
# Return the non persistent services registered to the engine (which this engine consumes)
# @return [Array]
get '/v0/containers/engine/:engine_name/services/non_persistent/' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engines_api.list_non_persistent_services(engine)

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r,  engine.last_error)
  end
end

# @method get_engine_non_persistent_services_by_type
# @overload get '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/:type_path'
# Return the non persistent services matchedin the :publisher_namespace and :type_path registered to the engine (which this engine consumes)
# @return [Array]

get '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/*' do
  hash = Utils::ServiceHash.engine_service_hash_from_params(params, true)
  r = engines_api.find_engine_service_hashes(hash) #find_engine_services_hashes(hash)

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request,  r, hash)
  end
end
# @!endgroup
