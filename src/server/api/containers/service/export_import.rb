# @!group /containers/service/:service_name
# @method engine_export_persistent_service_data
# @overload get '/v0/containers/service/:service_name/export'
# exports the service data as a gzip
# @return [octet-stream]
get '/v0/containers/service/:service_name/export' do
  STDERR.puts('Sex EXPORT')
  begin
    service = get_service(params[:service_name])
#    unless SoftwareServiceDefinition.is_consumer_exportable?(hash)
#         raise EnginesException.new(warning_hash("Cannot export as single service", hash))
#        end 
    raise EnginesException.new(warning_hash('Service not running')) unless service.is_running?
    content_type 'application/octet-stream'  
    stream do |out|
      begin
           service.export_data(out)
      rescue => e
        send_encoded_exception(request: request, params: params, exception: e)
      end
         end    
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end


options '/v0/containers/service/certs/import' do
    response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token, Origin, X-Requested-With, cache-control"
    response.headers["Access-Control-Allow-Origin"] = "*"
  STDERR.puts('SIN IMPORT:' + response.headers.to_s)
    200
  end 

# @method engine_import_persistent_service_data
# @overload put '/v0/containers/service/:service_name/import'
# import the service data gzip optional
# data is streamed as application/octet-stream
# @return [true]
post '/v0/containers/service/:service_name/import' do
  STDERR.puts('SIN IMPORT:' + request.to_s)
  begin
    response.headers['Access-Control-Allow-Origin'] = '*' 
    service = get_service(params[:service_name])
    # return_json(service.import_data(request.env['rack.input']))
    # return_json(service.import_data(request.body)) 
      r = request.env['rack.input']
    STDERR.puts('SIN IMPORT:' + response.headers.to_s)
      STDERR.puts('SIN IMPORT params' + params.to_s)
    #   STDERR.puts('SIN IMPORT ' + request.body.read)
      
      STDERR.puts('SIN IMPORT ' + r.class.name)
      return_json(service.import_data(request.env['rack.input']))

  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end