# @!group /system/reserved/

# @method get_system_reserved_port
# @overload get '/v0/system/reserved/ports'
#
# @return [Array]
#  array of integers
get '/v0/system/reserved/ports' do
  reserved_ports = engines_api.reserved_ports
  return log_error(request, reserved_ports) if reserved_ports.is_a?(EnginesError)
  status(202)
  reserved_ports.to_json
end

# @method get_system_reserved_hostnames
# @overload get '/v0/system/reserved/hostnames'
#
# @return [Array]
#  array of taken fqdn hostnames
get '/v0/system/reserved/hostnames' do
  reserved_hostnames = engines_api.taken_hostnames
  return log_error(request, reserved_hostnames) if reserved_hostnames.is_a?(EnginesError)
  status(202)
  reserved_hostnames.to_json
end

# @method get_system_reserved_engine_names
# @overload get '/v0/system/reserved/engine_names'
#
# @return [Array]
#  array of taken  and reserved engine_names
get '/v0/system/reserved/engine_names' do
  engine_names = engines_api.reserved_engine_names
  return log_error(request, engine_names) if engine_names.is_a?(EnginesError)
  status(202)
  engine_names.to_json
end
# @!endgroup