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
put '/v0/restore/registry/:replace/*' do
  begin
    unless params['splat'].nil?
      p = {
        replace: params[:replace],
        section: params['splat'][0]}
    else
      p = {
        replace: params[:replace],
        section: nil}
    end
    return_text(engines_api.restore_registry(request.env['rack.input'], p))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method restore_system_files
# @overload put '/v0/restore/system/files/:replace/:path'
#
#
# @return [true]
put '/v0/restore/system/files/:replace/*' do
  begin
    unless params['splat'].nil?
      p = {
        replace: params[:replace],
        path: params['splat'][0]}
    else
      p = {
        replace: params[:replace],
        path: nil}
    end

    engines_api.restore_system_files(request.env['rack.input'], p)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method restore_service
# @overload put '/v0/restore/service/:service_name/:replace/:section'
#
#
# @return [true]
put '/v0/restore/service/:service_name/:replace/*' do
  begin

    service = get_service(params[:service_name])
    unless params['splat'].nil?
      p = {
        replace: params[:replace],
        section: params['splat'][0]}
    else
      p = {
        replace: params[:replace],
        section: nil}
    end
    service.service_restore(request.env['rack.input'], p)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method restore_engine
# @overload put '/v0/restore/engine/:engine_name/:replace/:section'
#
#
# @return [true]
put '/v0/restore/engine/:engine_name/:replace/*' do
  begin
    unless params['splat'].nil?
      p = {
        replace: params[:replace],
        section: params['splat'][0]}
    else
      p = {
        replace: params[:replace],
        section: nil}
    end

    engines_api.restore_engine(request.env['rack.input'], p)

  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

put '/v0/restore/engines' do
  begin
    engines_api.restore_engines()
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end


# @method restore_engine
# @overload put '/v0/restore/engine_bundle/:engine_name'
#
#
# @return [true]
put '/v0/restore/bundle_engine/:engine_name' do
  begin
    unless params['splat'].nil?
      p = {
        replace: params[:replace],
        section: params['splat'][0]}
    else
      p = {
        replace: params[:replace],
        section: nil}
    end

    engines_api.restore_engine_bundle(request.env['rack.input'], p)

  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end