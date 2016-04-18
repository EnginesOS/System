#/containers/engines/state


#/containers/engines/container_name
#/containers/engines/


get '/v0/containers/engine/:id' do
  engine = get_engine(params[:id])
  unless engine.is_a?(FalseClass)
    return engine.to_json
  else
    return log_error('engine')
  end
end


