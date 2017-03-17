
# @!group /containers/engine/:engine_name/services/non_persistent/
# @method get_engine_non_persistent_services
# @overload get '/v0/containers/engine/:engine_name/services/non_persistent/'
# Return the non persistent services registered to the engine (which this engine consumes)
# @return [Array]
get '/v0/containers/engine/:engine_name/services/non_persistent/' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.nil?
  r = engines_api.list_non_persistent_services(engine)
  return log_error(request, r,  engine.last_error) if r.is_a?(EnginesError)
  return_json_array(r)
end

# @method add_engine_non_persistent_service
# @overload post '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/:type_path/'
#  add non persistent services in the :publisher_namespace and :type_path registered to the engine with posted params
# post api_vars :variables  
# @return [true|false]

post '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/*' do
  p_params = post_params(request)
  path_hash = engine_service_hash_from_params(params, true)
  p_params.merge!(path_hash)
  cparams = assemble_params(p_params, [:parent_engine,:publisher_namespace, :type_path], :all)
  return log_error(request,cparams,p_params) if cparams.is_a?(EnginesError)
    r =  engines_api.create_and_register_service(cparams)
  return log_error(request, r, cparams,to_s) if r.is_a?(EnginesError) 
  return_text(r)
end

# @method del_engine_non_persistent_service
# @overload delete '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/:type_path/:service_handle'
#  delete non persistent services sddressed by :publisher_namespace, :type_path :service_handle registered to the engine
# @return [true|false]

delete '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/*' do
  path_hash = engine_service_hash_from_params(params, false)
  cparams = assemble_params(path_hash, [:parent_engine, :publisher_namespace, :type_path, :service_handle], [])
  return log_error(request,cparams,path_hash)  if cparams.is_a?(EnginesError)
  r = engines_api.dettach_service(cparams)
  return log_error(request, r, cparams.to_s ) if r.is_a?(EnginesError)  
  return_text(r)
end


# @method get_engine_non_persistent_services_by_type
# @overload get '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/:type_path'
# Return the non persistent services matchedin the :publisher_namespace and :type_path registered to the engine (which this engine consumes)
# @return [Array]

get '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/*' do
  hash = engine_service_hash_from_params(params, true)
  r = engines_api.find_engine_service_hashes(hash) #find_engine_services_hashes(hash)
  return log_error(request,  r, hash) if r.is_a?(EnginesError)
  return_json(r)
end



# @!endgroup
