get '/v0/containers/engine/:id/service/non_persistent/:ns/*' do
  engine = get_engine(params[:id])
    
  r = @@core_api.container_memory_stats(engine)

  unless r.is_a?(FalseClass)
    return r
  else
    return log_error('non_persistent service')
  end
end