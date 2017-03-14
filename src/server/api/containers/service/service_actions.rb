# @!group /containers/service/:service_name
# @method create_service
# @overload get '/v0/containers/service/:service_name/create'
# create and start the service from the service image
# the local service image is updated prior to the container creation
# @return [true]
get '/v0/containers/service/:service_name/create' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  r = service.create_service
  return log_error(request, r, service.last_error) if r.is_a?(EnginesError)
  return_text(r)
end
# @method recreate_service
# @overload  get '/v0/containers/service/:service_name/recreate'
#  The service must be stopped first.
# Recreate the services container from the service image and start the service
#  The local service image is updated prior to the container creation
# @return [true]
get '/v0/containers/service/:service_name/recreate' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  r = service.recreate
  return log_error(request, r, service.last_error) if r.is_a?(EnginesError)
  return_text(r)
end
# @method stop_service
# @overload get '/v0/containers/service/:service_name/stop'
# stop the service
# @return [true]
get '/v0/containers/service/:service_name/stop' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  r = service.stop_container
  return log_error(request, r, service.last_error) if r.is_a?(EnginesError)
  return_text(r)
end
# @method stop_service
# @overload get '/v0/containers/service/:service_name/halt'
# stop the service without affecting set state
# @return [true]
get '/v0/containers/service/:service_name/halt' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  r = service.halt_container
  return log_error(request, r, service.last_error) if r.is_a?(EnginesError)
  return_text(r)
end
# @method start_service
# @overload get '/v0/containers/service/:service_name/start'
# start the service
# @return [true]
get '/v0/containers/service/:service_name/start' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  r = service.start_container
  return log_error(request, r, service.last_error) if r.is_a?(EnginesError)
  return_text(r)
end
# @method restart_service
# @overload get '/v0/containers/service/:service_name/restart'
# restart the service
# @return [true]
get '/v0/containers/service/:service_name/restart' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  r = service.restart_container
  return log_error(request, r, service.last_error) if r.is_a?(EnginesError)
  return_text(r)
end
# @method pause_service
# @overload get '/v0/containers/service/:service_name/pause'
# pause the service
# @return [true]
get '/v0/containers/service/:service_name/pause' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  r = service.pause_container
  return log_error(request, r, service.last_error) if r.is_a?(EnginesError)
  return_text(r)
end
# @method unpause_service
# @overload get '/v0/containers/service/:service_name/unpause'
# unpause the service
# @return [true]
get '/v0/containers/service/:service_name/unpause' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  r = service.unpause_container
  return log_error(request, r, service.last_error) if r.is_a?(EnginesError)
  return_text(r)
end

# @method destroy_service
# @overload delete '/v0/containers/service/:service_name/destroy'
# destroy the service container
# @return [true]
delete '/v0/containers/service/:service_name/destroy' do
  service = get_service(params[:service_name])
  return log_error(request, service, params) if service.is_a?(EnginesError)
  r = service.destroy_container
  return log_error(request, r, service.last_error) if r.is_a?(EnginesError)
  return_text(r)
end

# @method delete_service
# @overload delete '/v0/containers/service/:service_name/delete'
# delete the service from the system
# the service can be created again with fresh persistent services, no data is preserved beyond this point
# @return [true]
delete '/v0/containers/service/:service_name/delete' do
  r =  engines_api.remove_service(params[:service_name])
  return log_error(request, r) if r.is_a?(EnginesError)
  return_text(r)
end

# @!endgroup