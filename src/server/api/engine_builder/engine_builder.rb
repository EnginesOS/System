

get '/v0/engine_builder/status' do
 r = @@engines_api.build_status

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request)
  end
end

get '/v0/engine_builder/last_build/log' do
  r = @@engines_api.last_build_log
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request)
  end
end

get '/v0/engine_builder/last_build/params' do
  r = @@engines_api.last_build_params

  unless r.is_a?(FalseClass)
      return r.to_json
    else
      return log_error(request)
    end
  end
  out_h = nil
get '/v0/engine_builder/follow', provides: 'text/event-stream'  do
  stream :keep_open do |out|
    out_h = out
      settings.connections << out
      p out.to_s
      out.callback { settings.connections.delete(out) }
    end
  r = @@engines_api.follow_build(out_h)
#  r = @@engines_api.follow_build
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error(request)
 end
end