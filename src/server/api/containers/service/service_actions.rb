# @!group /containers/service/:service_name
# @method create_service
# @overload get '/v0/containers/service/:service_name/create'
# create and start the service from the service image
# the local service image is updated prior to the container creation
# @return [true]
get '/v0/containers/service/:service_name/create' do
  begin
    service = get_service(params[:service_name])
    return_text(service.create_service)
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
    return_text(service.recreate)
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
    return_text(service.stop_container)
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
    return_text(service.halt_container)
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
    return_text(service.start_container)
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
    return_text(service.restart_container)
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
    return_text(service.pause_container)
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
    return_text(service.unpause_container)
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
    return_text(service.destroy_container)
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
    return_text(engines_api.remove_service(params[:service_name]))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
