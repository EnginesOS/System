# @!group  /system/control/base_os/

# @method restart_base_os
# @overload get '/v0/system/control/base_os/restart'
#  Restart the base OS
# @return [true]
get '/v0/system/control/base_os/restart' do
  begin
    restart = engines_api.restart_base_os
    return_text(restart)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end
# @method shutdown_base_os
# @overload post '/v0/system/control/base_os/shutdown'
# shutdown the base OS with params
# @param :reason
#  :reason
# @return [true]
post '/v0/system/control/base_os/shutdown' do
  begin
    p_params = post_params(request)
    cparams = assemble_params(p_params, [], [:reason])
    shutdown = cparams[:reason]
    r = engines_api.halt_base_os(shutdown)
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end
# @method update_base_os
# @overload get '/v0/system/control/base_os/update'
# update the base OS
# @return [true|false]
get '/v0/system/control/base_os/update' do
  begin
    system_update = engines_api.update_base_os
    return_text(system_update)
  rescue StandardError => e
    send_encoded_exception(request, e)
  end
end
# @!endgroup
