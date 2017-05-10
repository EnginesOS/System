# @!group  /system/control/base_os/

# @method restart_base_os
# @overload get '/v0/system/control/base_os/restart'
#  Restart the base OS
# @return [true]
# not in tests
get '/v0/system/control/base_os/restart' do
  begin
    return_text(engines_api.restart_base_os)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method shutdown_base_os
# @overload post '/v0/system/control/base_os/shutdown'
# shutdown the base OS with params
# @param :reason
#  :reason
# @return [true]
# not in tests
post '/v0/system/control/base_os/shutdown' do
  begin
    p_params = post_params(request)
    cparams = assemble_params(p_params, [], [:reason])
    shutdown = cparams[:reason]
    return_text(engines_api.halt_base_os(shutdown))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method update_base_os
# @overload get '/v0/system/control/base_os/update'
# update the base OS
# @return [true|false]
get '/v0/system/control/base_os/update' do
  begin
    return_text(engines_api.update_base_os)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method set system timezone
# @overload get '/v0/system/control/base_os/timezone'
# set system timezone
# post param :timezone
# @return [true|false]
post '/v0/system/control/base_os/timezone' do
  begin
    post_s = post_params(request)
    cparams = assemble_params(post_s, [], [:timezone])

    return_text(engines_api.set_timezone(cparams[:timezone]))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method get system timezone
# @overload get '/v0/system/control/base_os/timezone'
# get system timezone
# @return [String]
get '/v0/system/control/base_os/timezone' do
  begin
    return_text(engines_api.get_timezone())
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method set system locale
# @overload get '/v0/system/control/base_os/locale'
# set system locale
# post param :locale
# @return [true|false]
post '/v0/system/control/base_os/locale' do
  begin
    post_s = post_params(request)
    cparams = assemble_params(post_s, [], [:country_code, :lang_code])
    return_text(engines_api.set_locale(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end

end
# @method get system locale
# @overload get '/v0/system/control/base_os/locale'
# set system locale
# @return [String]
get '/v0/system/control/base_os/locale' do
  begin
    return_json(engines_api.get_locale())
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end

end
# @!endgroup
