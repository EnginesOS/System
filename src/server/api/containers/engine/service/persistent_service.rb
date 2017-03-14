# @!group /containers/engine/:engine_name/services/persistent/
require 'base64'

# @method engine_export_persistent_service
# @overload get '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/:type_path/:service_handle/export'
# exports the service data as a gzip
# @return [Binary]
get '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/*/export' do
  content_type 'application/octet-stream'
  hash = engine_service_hash_from_params(params)
  engine = get_engine(params[:engine_name])
  r = ''
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  stream do |out|
    r = engine.export_service_data(hash,out)
  end
  return log_error(request, r, engine.last_error)  if r.is_a?(EnginesError)

end
# @method engine_import_persistent_service
# @overload post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/:type_path/:service_handle/overwrite'
# import the service data gzip optional
# @param :data data to import
# @return [true]
post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/*/overwrite' do
#  p_params = request.env["rack.input"].read
#  STDERR.puts(' upload post '  + p_params.to_s + ' params '  + params.to_s)
  hash = {}
  hash[:service_connection] =  engine_service_hash_from_params(params)
  engine = get_engine(params[:engine_name])
  hash[:datafile] = params['file'][:tempfile]

 # hash[:data] = Base64.encode64( p_params['api_vars']['data'])
  return log_error(request, engine, hash) if engine.is_a?(EnginesError)
  r = engine.import_service_data(hash,File.new(hash[:datafile].path,'rb'))
  return log_error(request, r, engine.last_error) if r.is_a?(EnginesError)
  return_text(r)
end
# @method engine_import_persistent_service_file
# @overload post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/:type_path/:service_handle/import_file'
# import the service data gzip optional
# @param
# @return [true]
#post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/*/import_file' do
##  p_params = request.env["rack.input"].read
# # STDERR.puts(' upload post '  + p_params.to_s + ' params '  + params.to_s)
#  hash = {}
#  hash[:service_connection] =  engine_service_hash_from_params(params)
#  engine = get_engine(params[:engine_name])
# # hash[:data] = p_params['api_vars']['data']
#  file = p_params[:file][:tempfile]
#  return log_error(request, engine, hash) if engine.is_a?(EnginesError)
#  r = engine.import_service_data(hash, file)
#  return log_error(request, r, engine.last_error) if r.is_a?(EnginesError)
#  content_type 'text/plain' 
#  r.to_s
#end
# @method engine_replace_persistent_service_file
# @overload post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/:type_path/:service_handle/replace_file'
# import the service data gzip optional after dropping/deleting existing data
# @param :data data to import
# @return [true]
#post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/*/replace_file' do
# # p_params =request.env["rack.input"].read
# # STDERR.puts(' upload post '  + p_params.to_s + ' params '  + params.to_s)
#  hash = {}
#  hash[:service_connection] =  engine_service_hash_from_params(params)
#  engine = get_engine(params[:engine_name])
#  hash[:import_method] = :replace
#  hash[:datafile] = params[:tempfile]
#  file = p_params[:file][:tempfile]
#  return log_error(request, engine, hash) if engine.is_a?(EnginesError)
#  r = engine.import_service_data(hash,file)
#  return log_error(request, r, engine.last_error) if r.is_a?(EnginesError)
#  content_type 'text/plain' 
#  r.to_s
#end
# @method engine_replace_persistent_service
# @overload post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/:type_path/:service_handle/replace'
# import the service data gzip optional after dropping/deleting existing data
# @param :data data to import
# @return [true]
post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/*/replace' do
#  p_params = request.env["rack.input"].read
#  STDERR.puts(' upload post '  + p_params.to_s + ' params '  + params.to_s)
  hash = {}
  hash[:service_connection] =  engine_service_hash_from_params(params)
  engine = get_engine(params[:engine_name])
  hash[:import_method] = :replace
  hash[:datafile] = params['file'][:tempfile]
  return log_error(request, engine, hash) if engine.is_a?(EnginesError)
 # hash[:data] =Base64.encode64( p_params['api_vars']['data'])
  r = engine.import_service_data(hash, File.new(hash[:datafile].path,'rb'))
  return log_error(request, r, engine.last_error) if r.is_a?(EnginesError)
  return_text(r)
end



# @method get_engine_persistent_service
# @overload get '/v0/containers/engine/:engine_name/services/persistent/'
# Return the persistent services registered to the engine (which this engine consumes)
# @return [Array]

get '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/*' do
  hash = engine_service_hash_from_params(params)
  r = engines_api.find_engine_service_hash(hash)
  return log_error(request, r, hash) if r.is_a?(EnginesError)
  return_json(r)
end

# @method update_engine_persistent_service
# @overload post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/:type_path/:service_handle'
# update  persistent service in the :publisher_namespace :type_path and service_handle registered to the engine with posted params
# post api_vars :variables  Note attempts to change service_handle will fail
# @return [true|false]

post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/*' do
  p_params = post_params(request)
   path_hash = engine_service_hash_from_params(params, false)
   p_params.merge!(path_hash)
   cparams =  Utils::Params.assemble_params(p_params, [:parent_engine,:publisher_namespace, :type_path, :service_handle], :all)
   return log_error(request,cparams,p_params) if cparams.is_a?(EnginesError)
 
  r = engines_api.update_attached_service(cparams)
  return log_error(request, r, hash) if r.is_a?(EnginesError)
  return_text(r)
end

# @!endgroup