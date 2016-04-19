get '/v0/containers/engine/:id/services/persistent/' do
  #engine = get_engine(params[:id])
  r = @@core_api.engine_persistent_services(params[:id])
  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error('pause')
  end
end
