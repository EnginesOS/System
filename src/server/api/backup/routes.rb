get '/v0/backup/system_files' do
  begin
    content_type 'application/octet-stream'
    r = ''
    stream do |out|
      r = engines_api.backup_system_files(out)
    end
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

get '/v0/backup/system_db' do
  begin
    content_type 'application/octet-stream'
    r = ''
    stream do |out|
      r = engines_api.backup_system_db(out)
    end
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

get '/v0/backup/registry' do
  begin
    content_type 'application/octet-stream'
    stream do |out|
      engines_api.backup_system_registry(out)
    end
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

get '/v0/backup/service/:service_name' do
  begin
    content_type 'application/octet-stream'
    stream do |out|
      engines_api.backup_service_data(params[:service_name], out)
    end
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

get '/v0/backup/engine/services/:engine_name' do
  begin
    r = engines_api.engines_services_to_backup(params[:engine_name])
    return_json(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

get '/v0/backup/engine/:engine_name' do
  begin
    content_type 'application/octet-stream'
    stream do |out|
      engines_api.backup_engine_config(params[:engine_name], out)
    end
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

get '/v0/backup/engine/:engine_name/service/:publisher_namespace/*' do
  begin
    hash = engine_service_hash_from_params(params)
    service_hash = engines_api.retrieve_engine_service_hash(hash)
    content_type 'application/octet-stream'
    stream do |out|
      engines_api.backup_engine_service(service_hash, out)
    end
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
