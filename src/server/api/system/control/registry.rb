# @!group /system/control/registry/
# @method restart_registry
# @overload get '/v0/system/control/registry/restart'
# restart the registry container
# @return [true]
# test cd /opt/engines/tests/engines_tool/system/control/registry; make restart
get '/v0/system/control/registry/restart' do
  begin
    return_text(engines_api.force_registry_restart)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @!endgroup
