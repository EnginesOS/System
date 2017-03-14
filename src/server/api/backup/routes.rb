get '/v0/backup/system_files' do
  content_type 'application/octet-stream'
  r = ''
  stream do |out|
    r = engines_api.backup_system_files(out)
  end
  return log_error(request, r)  if r.is_a?(EnginesError)
end

get '/v0/backup/system_db' do
  content_type 'application/octet-stream'
  r = ''
   stream do |out|
     r = engines_api.backup_system_db(out)
   end
   return log_error(request, r)  if r.is_a?(EnginesError)
end

get '/v0/backup/registry' do
  content_type 'application/octet-stream'
  r = ''
   stream do |out|
     r = engines_api.backup_system_registry(out)
   end
   return log_error(request, r)  if r.is_a?(EnginesError)
end

get '/v0/backup/service/:service_name' do
  content_type 'application/octet-stream'
  r = ''
    stream do |out|
      r = engines_api.backup_service_data(params[:service_name],out)
    end
    return log_error(request, r)  if r.is_a?(EnginesError)
end

get '/v0/backup/engine/services/:engine_name' do
  
  r = engines_api.engines_services_to_backup(params[:engine_name])

    return log_error(request, r)  if r.is_a?(EnginesError)
  return_json(r)
end

get '/v0/backup/engine/:engine_name' do
  content_type 'application/octet-stream'
  r = ''
    stream do |out|
      r = engines_api.backup_engine_config(params[:engine_name], out)
    end
    return log_error(request, r)  if r.is_a?(EnginesError)
end

get '/v0/backup/engine/:engine_name/service/:publisher_namespace/*' do
  hash = engine_service_hash_from_params(params)
  r = ''
 # STDERR.puts('Using ' + hash.to_s )
  service_hash = engines_api.find_engine_service_hash(hash)
 # STDERR.puts('found ' + service_hash.to_s)
   return log_error(request, service_hash, hash) if service_hash.is_a?(EnginesError)
  content_type 'application/octet-stream'
    stream do |out|
      r = engines_api.backup_engine_service(service_hash,out)
    end
    return log_error(request, r)  if r.is_a?(EnginesError)
end
