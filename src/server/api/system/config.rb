# @!group /system/config/
# @method get_default_domain
# @overload get '/v0/system/config/default_domain'
# get the default system domain
#
# @return [String] default_domain
get '/v0/system/config/default_domain' do
  begin
    default_domain = engines_api.get_default_domain
    return_text(default_domain)
  rescue StandardError =>e
    log_error(request, e)
  end
end
# @method set_default_domain
# @overload post '/v0/system/config/default_domain'
# set the default system domain
# @param :default_domain
# @return  [true]
post '/v0/system/config/default_domain' do
  begin
    post_s = post_params(request)
    cparams = assemble_params(post_s, [], [:default_domain])
    default_domain = cparams[:default_domain]
    engines_api.set_default_domain(default_domain)
    return_text(true)
  rescue StandardError =>e
    log_error(request, e)
  end
end
# @!group /system/config/
# @method get_default_site
# @overload get '/v0/system/config/default_site'
# get the default system default_site
#
# @return [String] default_site
get '/v0/system/config/default_site' do
  begin
    default_site = engines_api.get_default_site
    return_text(default_site)
  rescue StandardError =>e
    log_error(request, e)
  end
end
# @method set_default_site
# @overload post '/v0/system/config/default_site'
# set the default site
# @param :default_site
# @return  [true]
post '/v0/system/config/default_site' do
  begin
    post_s = post_params(request)
    cparams = assemble_params(post_s, [], [:default_site])
    default_site = cparams[:default_site]
    r = engines_api.set_default_site(default_site)
    return_text(r)
  rescue StandardError =>e
    log_error(request, e)
  end
end
# @method set_hostname
# @overload post '/v0/system/config/hostname'
# set the hostname
# @param :host_name
# @return [true]
post '/v0/system/config/hostname' do
  begin
    post_s = post_params(request)
    cparams = assemble_params(post_s, [], [:host_name])
    hostname = cparams[:host_name]
    r = engines_api.set_hostname(hostname)
    return_text(r)
  rescue StandardError =>e
    log_error(request, e)
  end
end
# @method get_hostname
# @overload get '/v0/system/config/hostname'
# get the hostname
# @return [String] hostname
get '/v0/system/config/hostname' do
  begin
    hostname = engines_api.system_hostname
    return_text(hostname)
  rescue StandardError =>e
    log_error(request, e)
  end
end
# @method enable_remote_exception_logging
# @overload post '/v0/system/config/remote_exception_logging/enable'
# enable remote_exception_logging setting
# @return [true]
post '/v0/system/config/remote_exception_logging/enable' do
  begin
    r = engines_api.enable_remote_exception_logging
    STDERR.puts('post /v0/system/config/remote_exception_logging/enable ' + r.to_s)
    return_text(r)
  rescue StandardError =>e
    log_error(request, e)
  end
end
# @method disable_remote_exception_logging
# @overload post '/v0/system/config/remote_exception_logging/disable'
# disable remote_exception_logging setting
# @return [true]
post '/v0/system/config/remote_exception_logging/disable' do
  begin
    r = engines_api.disable_remote_exception_logging
    STDERR.puts('post /v0/system/config/remote_exception_logging/enable ' + r.to_s)
    return_text(r)
  rescue StandardError =>e
    log_error(request, e)
  end
end
# @method get_remote_exception_logging
# @overload get '/v0/system/config/remote_exception_logging'
# get the remote_exception_logging setting
# @return [true|false] remote_exception_logging setting
get '/v0/system/config/remote_exception_logging' do
  begin
    r = SystemStatus.is_remote_exception_logging?
    return_text(r)
  rescue StandardError =>e
    log_error(request, e)
  end
end
# @!endgroup
