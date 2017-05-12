# @method run_engine_cron_job
# @overload   get '/v0/cron/engine/:engine_name/:cron_job/run'
#  run cron_job for engine
# @return [String] true|false
get '/v0/cron/engine/:engine_name/:cron_job/run' do
  begin
    engine = get_engine(params[:engine_name])
    return_text(engine.run_cronjob(params[:cron_job]))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method run_engine_schedule_container_ask
# @overload   get '/v0/schedule/engine/:engine_name/:cron_job'
#  run cron_job for engine
# @return [String] true|false
get '/v0/schedule/engine/:engine_name/:cron_job' do
  begin
    engine = get_engine(params[:engine_name])
    case params[:cron_job]
    when 'restart'
      r = engine.restart_container
    when 'start'
      r = engine.start_container
    when 'stop'
      r = engine.stop_container
    when 'pause'
      r = engine.pause_container
    when 'unpause'
      r = engine.unpause_container
    else
      send_encoded_exception(request, params[:cron_job], params[:engine_name])
    end
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method run_engine_schedule_action
get '/v0/schedule/engine/:engine_name/:cron_job/run' do
  begin
    engine = get_engine(params[:engine_name])
    return_text(engine.run_cronjob(params[:cron_job]))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

get '/v0/schedule/engine/:engine_name/cron_jobs' do
begin
  engine = get_engine(params[:engine_name])
  return_json(engine.cron_jobs)
rescue StandardError => e
  send_encoded_exception(request: request, exception: e)
end
end

# @!endgroup
