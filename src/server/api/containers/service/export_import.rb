# @!group /containers/service/:service_name
# @method engine_export_persistent_service_data
# @overload get '/v0/containers/service/:service_name/export'
# exports the service data as a gzip
# @return [Binary]
get '/v0/containers/service/:service_name/export' do
  begin
    service = get_service(params[:service_name])
#    unless SoftwareServiceDefinition.is_consumer_exportable?(hash)
#         raise EnginesException.new(warning_hash("Cannot export as single service", hash))
#        end 
    content_type 'application/octet-stream'  
    stream do |out|
           service.export_data(out)
         end    
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method engine_import_persistent_service_data
# @overload put '/v0/containers/service/:service_name/import'
# import the service data gzip optional
# data is streamed as application/octet-stream
# @return [true]
put '/v0/containers/service/:service_name/import' do
  begin
    service = get_service(params[:service_name])
  
        return_json(service.import_data(request.env['rack.input']))
   # return_json(service.import_data(request.body)) 
   
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end