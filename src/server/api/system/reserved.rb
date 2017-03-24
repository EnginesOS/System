# @!group /system/reserved/

# @method get_system_reserved_port
# @overload get '/v0/system/reserved/ports'
#
# @return [Array]
#  array of integers
get '/v0/system/reserved/ports' do
  begin
    return_json_array(engines_api.reserved_ports)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_system_reserved_hostnames
# @overload get '/v0/system/reserved/hostnames'
#
# @return [Array]
#  array of taken fqdn hostnames
get '/v0/system/reserved/hostnames' do
  begin
    return_json_array(engines_api.taken_hostnames)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_system_reserved_engine_names
# @overload get '/v0/system/reserved/engine_names'
#
# @return [Array]
#  array of taken  and reserved engine_names
get '/v0/system/reserved/engine_names' do
  begin
    return_json_array(engines_api.reserved_engine_names)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
