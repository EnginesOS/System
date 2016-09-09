
# @!group /containers/engine/:engine_name/services/non_persistent/
# @method get_engine_non_persistent_services
# @overload get '/v0/containers/engine/:engine_name/services/non_persistent/'
# Return the non persistent services registered to the engine (which this engine consumes)
# @return [Array]
get '/v0/containers/engine/:engine_name/services/non_persistent/' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engines_api.list_non_persistent_services(engine)
  return log_error(request, r,  engine.last_error) if r.is_a?(EnginesError)
  r.to_json  
end

# @method add_engine_non_persistent_service
# @overload post '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/:type_path/:service_handle'
#  ad non persistent services in the :publisher_namespace and :type_path registered to the engine with posted params
# @return [true|false]

post '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/*' do
  p_params = post_params(request)
  STDERR.puts( 'POST NONPER Ser paht Post:' + p_params.to_s )
  path_hash = Utils::ServiceHash.engine_service_hash_from_params(params, false)
  STDERR.puts( 'POST NONPER Ser paht' + path_hash.to_s + ' Post:' + p_params.to_s )
  p_params.merge!(path_hash)
  STDERR.puts( 'POST NONPER MEFE:' + p_params.to_s)
  cparams =  Utils::Params.assemble_params(p_params, [:engine_name,:publisher_namespace], :all)
  return log_error(request,cparams,p_params) if cparams.is_a?(EnginesError)
    r =  engines_api.create_and_register_service(cparams)
  return log_error(request, r, cparams,to_s) if r.is_a?(EnginesError) 
  content_type 'text/plain' 
  r.to_s
end

# @method del_engine_non_persistent_service
# @overload delete '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/:type_path'
#  ad non persistent services in the :publisher_namespace and :type_path registered to the engine with posted params
# @return [true|false]

delete '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/*' do
  path_hash = Utils::ServiceHash.engine_service_hash_from_params(params, false)
  cparams =  Utils::Params.assemble_params(path_hash, [:engine_name, :publisher_namespace, :type_path, :service_handle], :all)
  return log_error(request,cparams,p_params)  if cparams.is_a?(EnginesError)
  r = engines_api.dettach_service(cparams)
  return log_error(request, r, cparams.to_s ) if r.is_a?(EnginesError)  
  content_type 'text/plain' 
  r.to_s
end


# @method get_engine_non_persistent_services_by_type
# @overload get '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/:type_path'
# Return the non persistent services matchedin the :publisher_namespace and :type_path registered to the engine (which this engine consumes)
# @return [Array]

get '/v0/containers/engine/:engine_name/services/non_persistent/:publisher_namespace/*' do
  hash = Utils::ServiceHash.engine_service_hash_from_params(params, true)
  r = engines_api.find_engine_service_hashes(hash) #find_engine_services_hashes(hash)
  return log_error(request,  r, hash) if r.is_a?(EnginesError)
  r.to_json 
end



# @!endgroup
