# @!group /containers/engine/:engine_name/services/persistent/
# @method get_engine_persistent_services
# @overload get '/v0/containers/engine/:engine_name/services/persistent/'
# Return the persistent services registered to the engine (which this engine consumes)
# @return [Array]
get '/v0/containers/engine/:engine_name/services/persistent/' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engines_api.list_persistent_services(engine)
  return log_error(request, r, params[:engine_name]) if r.is_a?(EnginesError)
  r.to_json
end



# @method get_engine_persistent_services_by_type
# @overload get '/v0/containers/engine/:engine_name/services/persistent/:publisher_namespace/:type_path'
# Return the persistent services matchedin the :publisher_namespace and :type_path registered to the engine (which this engine consumes)
# @return [Array]

get '/v0/containers/engine/:engine_name/services/persistent/:publisher_namespace/*' do

    
  hash = Utils::ServiceHash.engine_service_hash_from_params(params, true)

  r = engines_api.find_engine_service_hashes(hash) #find_engine_services_hashes(hash)

  return log_error(request, r, hash) if r.is_a?(EnginesError)
   r.to_json
end

# @!endgroup