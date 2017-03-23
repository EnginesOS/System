# @method run_service_cron_job
# @overload   get '/v0/cron/service/:service_name/:cron_job/run'
#  run cron_job for service
# @return [String] true|false
get '/v0/cron/service/:service_name/:cron_job/run' do
  begin
    service = get_service(params[:service_name])
    r = service.run_cronjob(params[:cron_job])
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method run_service_schedule_container_task
# @overload   get '/v0/schedule/service/:service_name/:cron_job'
# cron_job restart|start|
#  run cron_job for service
# @return [String] true|false|stop|pause|unpause|create
get '/v0/schedule/service/:service_name/:cron_job' do
  begin
    service = get_service(params[:service_name])
    case params[:cron_job]
    when 'restart'
      r = service.restart_container
    when 'start'
      r = service.start_container
    when 'stop'
      r = service.stop_container
    when 'pause'
      r = service.pause_container
    when 'unpause'
      r = service.unpause_container
    when 'create'
      r = service.create_container
    else
      send_encoded_exception(request, params[:cron_job], params[:service_name])
    end
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method run_engine_schedule_action
get '/v0/schedule/service/:service_name/:cron_job/run' do
  begin
    service = get_service(params[:service_name])
    r = service.run_cronjob(params[:cron_job])
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
