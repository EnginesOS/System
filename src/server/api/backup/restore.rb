# @!group /restore/
# @method restore_system
# @overload put '/v0/restore/system/:section'
#
#
# @return [true]
put '/v0/restore/system/:section' do
  begin
    return_text(engines_api.restore_system(params[:section], request.env['rack.input']))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method restore_registry
# @overload put 'v0/restore/registry'
#
#
# @return [true]
put '/v0/restore/registry' do
  begin
    return_text(engines_api.restore_registry(request.env['rack.input']))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method restore_service
# @overload put '/v0/restore/service/:service_name/:section'
#
#
# @return [true]
post '/v0/restore/service/:service_name/*' do
  begin
    
    service = get_service(params[:service_name])
    unless params['splat'].nil?
      p = {section: params['splat'][0]}
    else
      p = {section: nil}
    end
    service.service_restore(request.env['rack.input'], p)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

