# @!group /containers/service/:service_name/service/persistent/
# @method service_export_persistent_service
# @overload get '/v0/containers/service/:service_name/service/persistent/:publisher_namespace/:type_path/:service_handle/export'
# exports the service data as a gzip
# @return [Binary]
get '/v0/containers/service/:service_name/service/persistent/:publisher_namespace/*/export' do
  begin
    content_type 'application/octet-stream'
    hash = service_service_hash_from_params(params)
    service = get_service(params[:service_name])
    r = service.export_service_data(hash)
    content_type 'binary/octet-stream'
    r.b
  rescue StandardError =>e
    log_error(request, e)
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
    hash[:service_connection] =  service_service_hash_from_params(params)
    return log_error(request, 'Service not found', hash) if hash[:service_connection] .is_a?(FalseClass)
    service = get_service(params[:service_name])
    hash[:data]  = params[:data]
    r = service.import_service_data(hash)
    return_text(r)
  rescue StandardError =>e
    log_error(request, e)
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
    hash[:service_connection] =  service_service_hash_from_params(params)
    return log_error(request, 'Service not found', hash) if  hash[:service_connection].is_a?(FalseClass)
    service = get_service(params[:service_name])
    hash[:import_method] == :replace
    hash[:data] = params[:data]
    r = service.import_service_data(hash)
    return_text(r)
  rescue StandardError =>e
    log_error(request, e)
  end
end

# @method service_get_persistent_service
# @overload get '/v0/containers/service/:service_name/service/persistent/:publisher_namespace/:type_path/:service_handle'
# get the service
# @return [Hash]
get '/v0/containers/service/:service_name/service/persistent/:publisher_namespace/*' do
  begin
    hash = service_service_hash_from_params(params)
    r = engines_api.find_service_service_hash(hash)
    return_json(r)
  rescue StandardError =>e
    log_error(request, e)
  end
end
# @!endgroup