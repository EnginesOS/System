# @!group /containers/engine/:engine_name/services/persistent/

# @method engine_export_persistent_service
# @overload get '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/:type_path/:service_handle/export'
# exports the service data as a gzip
# @return [Binary]
get '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/*/export' do
  content_type 'application/octet-stream'
  hash = Utils::ServiceHash.engine_service_hash_from_params(params)
  engine = get_engine(params[:engine_name])
  r = ''
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  stream do |out|
   r = engine.export_service_data(hash,out)
  end
  if r.is_a?(EnginesError)
    return log_error(request, r, engine.last_error)
  end
end
# @method engine_import_persistent_service
# @overload post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/:type_path/:service_handle/import'
# import the service data gzip optional 
# @param :data data to import
# @return [true]
post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/*/import' do
  p_params = post_params(request)
  hash = {}
  hash[:service_connection] =  Utils::ServiceHash.engine_service_hash_from_params(params)
  engine = get_engine(params[:engine_name])
  hash[:data]  = p_params[:data]
  return log_error(request, engine, hash) if engine.is_a?(EnginesError)
  r = engine.import_service_data(hash)
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end
# @method engine_import_persistent_service_file
# @overload post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/:type_path/:service_handle/import_file'
# import the service data gzip optional 
# @param 
# @return [true]
post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/*/import_file' do
  p_params = post_params(request)
  hash = {}
  hash[:service_connection] =  Utils::ServiceHash.engine_service_hash_from_params(params)
  engine = get_engine(params[:engine_name])
  hash[:data]  = p_params[:data]
  file = p_params[:file][:tempfile]
  return log_error(request, engine, hash) if engine.is_a?(EnginesError)
  
  r = engine.import_service_data(hash, file)
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end
# @method engine_replace_persistent_service_file
# @overload post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/:type_path/:service_handle/replace_file'
# import the service data gzip optional after dropping/deleting existing data
# @param :data data to import
# @return [true]
post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/*/replace_file' do
  p_params = post_params(request)
  hash = {}
   hash[:service_connection] =  Utils::ServiceHash.engine_service_hash_from_params(params)
   engine = get_engine(params[:engine_name])
  hash[:import_method] = :replace  
  hash[:data] = p_params[:data]
  file = p_params[:file][:tempfile]
  return log_error(request, engine, hash) if engine.is_a?(EnginesError)
  r = engine.import_service_data(hash,file)
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end
# @method engine_replace_persistent_service
# @overload post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/:type_path/:service_handle/replace'
# import the service data gzip optional after dropping/deleting existing data
# @param :data data to import
# @return [true]
post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/*/replace' do
  p_params = post_params(request)
  hash = {}
   hash[:service_connection] =  Utils::ServiceHash.engine_service_hash_from_params(params)
   engine = get_engine(params[:engine_name])
  hash[:import_method] = :replace  
  hash[:data] = p_params[:data]
    STDERR.puts(' data passed ' + p_params.to_s)
  return log_error(request, engine, hash) if engine.is_a?(EnginesError)
  r = engine.import_service_data(hash)
  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, engine.last_error)
  end
end


# @method get_engine_persistent_service
# @overload get '/v0/containers/engine/:sengine_name/services/persistent/'
# Return the persistent services registered to the engine (which this engine consumes)
# @return [Array]

get '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/*' do
  
  hash = Utils::ServiceHash.engine_service_hash_from_params(params)

  r = engines_api.find_engine_service_hash(hash)

  unless r.is_a?(EnginesError)
    return r.to_json
  else
    return log_error(request, r, hash)
  end
end
# @!endgroup