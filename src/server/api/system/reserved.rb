#/system/reserved/engine_names List
#/system/reserved/hostnames List
#/system/reserved/ports
get '/v0/system/reserved/ports' do
  reserved_ports = engines_api.reserved_ports
  unless reserved_ports.is_a?(EnginesError)
    status(202)
    return reserved_ports.to_json
  else
    return log_error(request, reserved_ports)
  end
end

get '/v0/system/reserved/hostnames' do
  reserved_hostnames = engines_api.taken_hostnames
  unless reserved_hostnames.is_a?(EnginesError)
    status(202)
    return reserved_hostnames.to_json
    
  else
    return log_error(request, reserved_hostnames)
  end
end

get '/v0/system/reserved/engine_names' do
  engine_names = engines_api.reserved_engine_names
  unless engine_names.is_a?(EnginesError)
    status(202)
    return engine_names.to_json
  else
    return log_error(request, engine_names)
  end
end
