


get '/v0/containers/service/:service_name/consumers/:parent_engine/:service_handle' do
  service = get_service(params[:service_name])
    return false if service.is_a?(FalseClass)
    
  r = service.registered_consumer(params)

  unless r.is_a?(FalseClass)
    return r.to_json
  else
    return log_error('consumers')
  end
end