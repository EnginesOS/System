# @!group /system/config/

# @method get_default_domain
# @overload get '/v0/system/config/default_domain'
# get the default system domain
#
# @return [String] default_domain
#test cd /opt/engines/tests/engines_api/system/config ;  make default_domain
get '/v0/system/config/default_domain' do
  begin
    return_text( engines_api.get_default_domain)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method set_default_domain
# @overload post '/v0/system/config/default_domain'
# set the default system domain
# @param :default_domain
# @return  [true]
#test cd /opt/engines/tests/engines_api/system/config ;  make set_default_domain
post '/v0/system/config/default_domain' do
  begin
    post_s = post_params(request)
    cparams = assemble_params(post_s, [], [:default_domain])
    default_domain = cparams[:default_domain]
    engines_api.set_default_domain(default_domain)
    return_true
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @!group /system/config/
# @method get_default_site
# @overload get '/v0/system/config/default_site'
# get the default system default_site
#
# @return [String] default_site
#test cd /opt/engines/tests/engines_api/system/config ;  make default_site
get '/v0/system/config/default_site' do
  begin
    return_text(engines_api.get_default_site)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method set_default_site
# @overload post '/v0/system/config/default_site'
# set the default site
# @param :default_site
# @return  [true]
#test cd /opt/engines/tests/engines_api/system/config ;  make set_default_site
post '/v0/system/config/default_site' do
  begin
    post_s = post_params(request)
    cparams = assemble_params(post_s, [], [:default_site])
    default_site = cparams[:default_site]
    return_boolean(engines_api.set_default_site(default_site))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method set_hostname
# @overload post '/v0/system/config/hostname'
# set the hostname
# @param :host_name
# @return [true]
#test cd /opt/engines/tests/engines_api/system/config ;  make  set_hostname
post '/v0/system/config/hostname' do
  begin
    post_s = post_params(request)
    cparams = assemble_params(post_s, [], [:host_name])
    hostname = cparams[:host_name]
    return_text(engines_api.set_hostname(hostname))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
  #test cd /opt/engines/tests/engines_api/system/config ;  make  set_hostname
end

# @method get_hostname
# @overload get '/v0/system/config/hostname'
# get the hostname
# @return [String] hostname
#test cd /opt/engines/tests/engines_api/system/config ;  make  hostname
get '/v0/system/config/hostname' do
  begin
    return_text(engines_api.system_hostname)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method enable_remote_exception_logging
# @overload post '/v0/system/config/remote_exception_logging/enable'
# enable remote_exception_logging setting
# @return [true]
#test cd /opt/engines/tests/engines_api/system/config ;  make  set_remote_exception_logging
post '/v0/system/config/remote_exception_logging/enable' do
  begin
    return_text(engines_api.enable_remote_exception_logging)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method disable_remote_exception_logging
# @overload post '/v0/system/config/remote_exception_logging/disable'
# disable remote_exception_logging setting
# @return [true]
#test cd /opt/engines/tests/engines_api/system/config ;  make  set_remote_exception_logging
post '/v0/system/config/remote_exception_logging/disable' do
  begin
    return_text(engines_api.disable_remote_exception_logging)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

#test cd /opt/engines/tests/engines_api/system/config ;  make remote_exception_logging
# @method get_remote_exception_logging
# @overload get '/v0/system/config/remote_exception_logging'
# get the remote_exception_logging setting
# @return [true|false] remote_exception_logging setting
get '/v0/system/config/remote_exception_logging' do
  begin
    return_text(SystemStatus.is_remote_exception_logging?)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
