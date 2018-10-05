# @!group /containers/engine/:engine_name/services/persistent/
require 'base64'

# @method engine_export_persistent_service
# @overload get '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/:type_path/:service_handle/export'
# exports the service data as a gzip
# @returns octal stream
get '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/*/export' do
  begin
    hash = engine_service_hash_from_params(params)
    unless SoftwareServiceDefinition.is_consumer_exportable?(hash)
     raise EnginesException.new(warning_hash("Cannot export as single service", hash))
    end 
    engine = get_engine(params[:engine_name])
    content_type 'application/octet-stream'   
    unless engine.nil?
      stream do |out|
        begin
        engine.export_service_data(hash, out)
          STDERR.puts('export service ');
        rescue StandardError => e
          STDERR.puts('exception ' + e.to_s)
          out.reset
        end
      end
    else
      send_encoded_exception(request: request, engine: engine, params: params, exception: nil)
    end
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method engine_import_persistent_service
# @overload put '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/:type_path/:service_handle/overwrite'
# import the service data gzip optional
# data is streamed as application/octet-stream
# @return [true]
put '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/*/overwrite' do
  begin
    hash = engine_service_hash_from_params(params)
    unless SoftwareServiceDefinition.is_consumer_exportable?(hash)
       raise EnginesException.new(warning_hash("Cannot import as single service", hash))
      end 
    engine = get_engine(params[:engine_name])
    return_text(engine.import_service_data(
    {service_connection: engine_service_hash_from_params(params) },
    request.env['rack.input']))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method engine_replace_persistent_service
# @overload put '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/:type_path/:service_handle/replace'
# import the service data gzip optional after dropping/deleting existing data
# data is streamed as application/octet-stream
# @return [true]
put '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/*/replace' do
  begin
    hash = engine_service_hash_from_params(params)
    unless SoftwareServiceDefinition.is_consumer_exportable?(hash)     
       send_encoded_exception(request: request, 
         exception: EnginesException.new(warning_hash("Cannot import as single service", hash)))
    else 
    engine = get_engine(params[:engine_name])
    return_text(engine.import_service_data(
    {service_connection: engine_service_hash_from_params(params)},
    request.env['rack.input']))
  end
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_engine_persistent_service
# @overload get '/v0/containers/engine/:engine_name/services/persistent/'
# Return the persistent services registered to the engine (which this engine consumes)
# @return [Array]

get '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/*' do
  begin
    hash = engine_service_hash_from_params(params)
    return_json(engines_api.retrieve_engine_service_hash(hash))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method update_engine_persistent_service
# @overload post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/:type_path/:service_handle'
# update  persistent service in the :publisher_namespace :type_path and service_handle registered to the engine with posted params
# post api_vars :variables  Note attempts to change service_handle will fail
# @return [true|false]

post '/v0/containers/engine/:engine_name/service/persistent/:publisher_namespace/*' do
  begin
    p_params = post_params(request)
    path_hash = engine_service_hash_from_params(params, false)
    p_params.merge!(path_hash)
    cparams = assemble_params(p_params, [:parent_engine, :publisher_namespace, :type_path, :service_handle], :all)
    return_text(engines_api.update_attached_service(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @!endgroup
