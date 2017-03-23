# @!group /containers/service/:service_name
# @method create_service
# @overload get '/v0/containers/service/:service_name/create'
# create and start the service from the service image
# the local service image is updated prior to the container creation
# @return [true]
get '/v0/containers/service/:service_name/create' do
  begin
    service = get_service(params[:service_name])
    r = service.create_service
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method recreate_service
# @overload  get '/v0/containers/service/:service_name/recreate'
#  The service must be stopped first.
# Recreate the services container from the service image and start the service
#  The local service image is updated prior to the container creation
# @return [true]
get '/v0/containers/service/:service_name/recreate' do
  begin
    service = get_service(params[:service_name])
    r = service.recreate
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method stop_service
# @overload get '/v0/containers/service/:service_name/stop'
# stop the service
# @return [true]
get '/v0/containers/service/:service_name/stop' do
  begin
    service = get_service(params[:service_name])
    r = service.stop_container
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method stop_service
# @overload get '/v0/containers/service/:service_name/halt'
# stop the service without affecting set state
# @return [true]
get '/v0/containers/service/:service_name/halt' do
  begin
    service = get_service(params[:service_name])
    r = service.halt_container
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method start_service
# @overload get '/v0/containers/service/:service_name/start'
# start the service
# @return [true]
get '/v0/containers/service/:service_name/start' do
  begin
    service = get_service(params[:service_name])
    r = service.start_container
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method restart_service
# @overload get '/v0/containers/service/:service_name/restart'
# restart the service
# @return [true]
get '/v0/containers/service/:service_name/restart' do
  begin
    service = get_service(params[:service_name])
    r = service.restart_container
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method pause_service
# @overload get '/v0/containers/service/:service_name/pause'
# pause the service
# @return [true]
get '/v0/containers/service/:service_name/pause' do
  begin
    service = get_service(params[:service_name])
    r = service.pause_container
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method unpause_service
# @overload get '/v0/containers/service/:service_name/unpause'
# unpause the service
# @return [true]
get '/v0/containers/service/:service_name/unpause' do
  begin
    service = get_service(params[:service_name])
    r = service.unpause_container
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method destroy_service
# @overload delete '/v0/containers/service/:service_name/destroy'
# destroy the service container
# @return [true]
delete '/v0/containers/service/:service_name/destroy' do
  begin
    service = get_service(params[:service_name])
    r = service.destroy_container
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method delete_service
# @overload delete '/v0/containers/service/:service_name/delete'
# delete the service from the system
# the service can be created again with fresh persistent services, no data is preserved beyond this point
# @return [true]
delete '/v0/containers/service/:service_name/delete' do
  begin
    r = engines_api.remove_service(params[:service_name])
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
