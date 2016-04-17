
  
  #/system/reserved/engine_names List
  #/system/reserved/hostnames List
  #/system/reserved/ports
get '/v0/system/reserved/ports' do
  reserved_ports = @@core_api.reserved_ports
  unless reserved_ports.is_a?(FalseClass)
    return reserved_ports.to_json
  else
    return log_error('reserved_ports')
  end
end

get '/v0/system/reserved/hostnames' do
  reserved_hostnames = @@core_api.reserved_hostnames
  unless reserved_hostnames.is_a?(FalseClass)
    return reserved_hostnames.to_json
  else
    return log_error('reserved_hostnames')
  end
end

get '/v0/system/mreserved/engine_names' do
  engine_names = @@core_api.reserved_engine_names
  unless engine_names.is_a?(FalseClass)
    return engine_names.to_json
  else
    return log_error('reserved_engine_names')
  end
end
