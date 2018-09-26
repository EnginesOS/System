# @!group /containers/service/:service_name/service/persistent/
# @method service_export_persistent_service
# @overload get '/v0/containers/service/:service_name/service/persistent/:publisher_namespace/:type_path/:service_handle/export'
# exports the service data as a gzip
# @return [octet-stream]
get '/v0/containers/service/:service_name/service/persistent/:publisher_namespace/*/export' do
  begin
    content_type 'application/octet-stream'
    hash = service_service_hash_from_params(params)
    service = get_service(params[:service_name])
    content_type 'binary/octet-stream'
    service.export_service_data(hash).b
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method service_import_persistent_service
# @overload get '/v0/containers/service/:service_name/service/persistent/:publisher_namespace/:type_path/:service_handle/import'
# import the service data gzip optional
# @param :data data to import
# @return [true]
get '/v0/containers/service/:service_name/service/persistent/:publisher_namespace/*/import' do
  begin
    hash = {}
    hash[:service_connection] = service_service_hash_from_params(params)
    service = get_service(params[:service_name])
    hash[:data] = params[:data]
    return_text(service.import_service_data(hash))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method service_replace_persistent_service
# @overload get '/v0/containers/service/:service_name/service/persistent/:publisher_namespace/:type_path/:service_handle/replace'
# import the service data gzip optional after dropping/deleting existing data
# @param :data data to import
# @return [true]
get '/v0/containers/service/:service_name/service/persistent/:publisher_namespace/*/replace' do
  begin
    hash = {}
    hash[:service_connection] = service_service_hash_from_params(params)
    service = get_service(params[:service_name])
    hash[:import_method] = :replace
    hash[:data] = params[:data]
    return_text(service.import_service_data(hash))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method service_get_persistent_service
# @overload get '/v0/containers/service/:service_name/service/persistent/:publisher_namespace/:type_path/:service_handle'
# get the service
# @return [Hash]
get '/v0/containers/service/:service_name/service/persistent/:publisher_namespace/*' do
  begin
    hash = service_service_hash_from_params(params)
    return_json(engines_api.find_service_service_hash(hash))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
