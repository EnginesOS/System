get '/v0/backup/system_files' do
  begin
    content_type 'application/octet-stream'
    stream do |out|
      begin
      engines_api.backup_system_files(out)       
      rescue StandardError => e
        STDERR.puts('engine_export_persistent_service exception ' + e.to_s)
        send_encoded_exception(request: request, exception: e)
      end
    end
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

get '/v0/backup/system_db' do
  begin
    content_type 'application/octet-stream'
    stream do |out|
      begin
      engines_api.backup_system_db(out)
      rescue StandardError => e
        STDERR.puts('engine_export_persistent_service exception ' + e.to_s)
        send_encoded_exception(request: request, exception: e)
      end
    end
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

get '/v0/backup/service/registry' do
  begin
    content_type 'application/octet-stream'
    stream do |out|
      begin
      engines_api.backup_system_registry(out)
        rescue StandardError => e
          STDERR.puts('engine_export_persistent_service exception ' + e.to_s)
          send_encoded_exception(request: request, exception: e)
        end
    end
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

get '/v0/backup/service/:service_name' do
  begin
    content_type 'application/octet-stream'
    stream do |out|
      begin
      engines_api.backup_service_data(params[:service_name], out)
        rescue StandardError => e
          STDERR.puts('engine_export_persistent_service exception ' + e.to_s)
          send_encoded_exception(request: request, exception: e)
        end
    end
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

get '/v0/backup/engine/services/:engine_name' do
  begin
    return_json(engines_api.engines_services_to_backup(params[:engine_name]))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

get '/v0/backup/engine/:engine_name' do
  begin
    content_type 'application/octet-stream'
    stream do |out|
      begin
      engines_api.backup_engine_config(params[:engine_name], out)
        rescue StandardError => e
          STDERR.puts('engine_export_persistent_service exception ' + e.to_s)
          send_encoded_exception(request: request, exception: e)
        end
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
      begin
      engines_api.backup_engine_service(service_hash, out)
        rescue StandardError => e
          STDERR.puts('engine_export_persistent_service exception ' + e.to_s)
          send_encoded_exception(request: request, exception: e)
        end
    end
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method backup_engine_bundle
# @overload put '/v0/backup/bundle_engine/:engine_name'
#
#
# @return [true]
get '/v0/backup/bundle_engine/:engine_name' do
  begin
    stream do |out|
      begin
      engines_api.engine_bundle(params[:engine_name], out)
        rescue StandardError => e
          STDERR.puts('engine_export_persistent_service exception ' + e.to_s)
          send_encoded_exception(request: request, exception: e)
        end
    end
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

