# @!group /restore/
# @method restore_system
# @overload put '/v0/restore/system/:section'
#
#
# @return [true]
#put '/v0/restore/system' do
#  begin
#    return_text(engines_api.restore_system_files(request.env['rack.input'], path))
#  rescue StandardError => e
#    send_encoded_exception(request: request, exception: e)
#  end
#end
#put '/v0/restore/system/*' do
#  begin
#   path = params['splat'][0]
#    return_text(engines_api.restore_system_files( request.env['rack.input'], path))
#  rescue StandardError => e
#    send_encoded_exception(request: request, exception: e)
#  end
#end
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

# @method restore_system_files
# @overload put '/v0/restore/system/files/:path'
#
#
# @return [true]
put '/v0/restore/system/files/*' do
  begin
    STDERR.puts('RESTORE SYSTEM_' )
    if params['splat'].is_a?(Array)
      path = params['splat'][0]
    else
      path = nil
    end  
    
    
    engines_api.restore_system_files(request.env['rack.input'], path)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method restore_service
# @overload put '/v0/restore/service/:service_name/:section'
#
#
# @return [true]
put '/v0/restore/service/:service_name/*' do
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

