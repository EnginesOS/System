# @method run_engine_cron_job
# @overload   get '/v0/cron/engine/:engine_name/:cron_job/run'
#  run cron_job for engine
# @return [String] true|false
get '/v0/cron/engine/:engine_name/:cron_job/run' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)
  r = engine.run_cronjob(params[:cron_job])
  return log_error(request, r, engine.last_error) if r.is_a?(EnginesError)
  return_text(r)
end

# @method run_engine_schedule_container_ask
# @overload   get '/v0/schedule/engine/:engine_name/:cron_job'
#  run cron_job for engine
# @return [String] true|false
get '/v0/schedule/engine/:engine_name/:cron_job' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)

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
    log_error(request,   params[:cron_job],params[:engine_name])
  end

  #  r = engine.run_cronjob(params[:cron_job])
  return log_error(request, r, engine.last_error) if r.is_a?(EnginesError)
  return_text(r)
end

# @method run_engine_schedule_action 
get '/v0/schedule/engine/:engine_name/:cron_job/run' do
  engine = get_engine(params[:engine_name])
  return log_error(request, engine, params) if engine.is_a?(EnginesError)  
 begin 
  r = engine.run_cronjob(params[:cron_job])
  return_text(r)
 rescue EnginesException => e
   return_error(e) 
   end
end