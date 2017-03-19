# @!group /system/control/registry/
# @method restart_registry
# @overload get '/v0/system/control/registry/restart'
# restart the registry container
# @return [true]
get '/v0/system/control/registry/restart' do
  begin
    restart_registry = engines_api.force_registry_restart
    return_text(restart_registry)
  rescue StandardError =>e
    log_error(request, e)
  end
end

# @!endgroup