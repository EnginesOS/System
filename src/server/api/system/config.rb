# @!group /system/config/
# @method get_default_domain 
# @overload get '/v0/system/config/default_domain'
# get the default system domain
# 
# @return [String] default_domain
get '/v0/system/config/default_domain' do
  default_domain = engines_api.get_default_domain
 return log_error(request, default_domain) if default_domain.is_a?(EnginesError)
  return_text(default_domain)
end
# @method set_default_domain 
# @overload post '/v0/system/config/default_domain'
# set the default system domain
# @param :default_domain
# @return  [true]
post '/v0/system/config/default_domain' do
  post_s = post_params(request)

  cparams = assemble_params(post_s, [], [:default_domain])
  return log_error(request, cparams, post_s) if cparams.is_a?(EnginesError)
  default_domain = cparams[:default_domain]
    r = engines_api.set_default_domain(default_domain)
 return log_error(request, r,  cparams)  if r.is_a?(EnginesError)
  return_text(r)
end
# @!group /system/config/
# @method get_default_site
# @overload get '/v0/system/config/default_site'
# get the default system default_site
# 
# @return [String] default_site
get '/v0/system/config/default_site' do
  default_site = engines_api.get_default_site
  return log_error(request, default_site) if default_site.is_a?(EnginesError)
  return_text(default_site)
end
# @method set_default_site 
# @overload post '/v0/system/config/default_site'
# set the default site
# @param :default_site
# @return  [true]
post '/v0/system/config/default_site' do
  post_s = post_params(request)
  cparams = assemble_params(post_s, [], [:default_site])
  return log_error(request, cparams, post_s) if cparams.is_a?(EnginesError)
  default_site = cparams[:default_site]
    r = engines_api.set_default_site(default_site)
 return log_error(request, r, cparams) if r.is_a?(EnginesError)
  return_text(r)
end
# @method set_hostname
# @overload post '/v0/system/config/hostname'
# set the hostname
# @param :host_name
# @return [true]
post '/v0/system/config/hostname' do
  post_s = post_params(request)
  cparams = assemble_params(post_s, [], [:host_name])
  return log_error(request, cparams, post_s) if cparams.is_a?(EnginesError)
  hostname = cparams[:host_name]
  r = engines_api.set_hostname(hostname)
  return log_error(request, r, cparams) if r.is_a?(EnginesError) 
  return_text(r)
end
# @method get_hostname
# @overload get '/v0/system/config/hostname'
# get the hostname
# @return [String] hostname
get '/v0/system/config/hostname' do
  hostname = engines_api.system_hostname
  return log_error(request, hostname) if hostname.is_a?(EnginesError)
  return_text(r)
end
# @method enable_remote_exception_logging
# @overload post '/v0/system/config/remote_exception_logging/enable'
# enable remote_exception_logging setting
# @return [true]
post '/v0/system/config/remote_exception_logging/enable' do
  r = engines_api.enable_remote_exception_logging
  return log_error(request, r) if r.is_a?(EnginesError)
  return_text(r)
end
# @method disable_remote_exception_logging
# @overload post '/v0/system/config/remote_exception_logging/disable'
# disable remote_exception_logging setting
# @return [true]
post '/v0/system/config/remote_exception_logging/disable' do
  r = engines_api.disable_remote_exception_logging
  return log_error(request, r) if r.is_a?(EnginesError)
  return_text(r)
end
# @method get_remote_exception_logging
# @overload get '/v0/system/config/remote_exception_logging'
# get the remote_exception_logging setting
# @return [true|false] remote_exception_logging setting
get '/v0/system/config/remote_exception_logging' do
  r = SystemStatus.is_remote_exception_logging?
  return log_error(request,r)  if r.is_a?(EnginesError)
  return_text(r)
end
# @!endgroup
