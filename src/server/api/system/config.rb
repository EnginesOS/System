# @!group /system/config/
# @method get_default_domain 
# @overload get '/v0/system/config/default_domain'
# get the default system domain
# 
# @return String|EnginesError.to_json
get '/v0/system/config/default_domain' do
  default_domain = engines_api.get_default_domain
  unless default_domain.is_a?(EnginesError)
    status(202)
    return default_domain.to_json
  else
    log_error(request, default_domain)
    status(404)
  end
end
# @method set_default_domain 
# @overload post '/v0/system/config/default_domain'
# set the default system domain
#  :default_domain
# @return  [true|EnginesError]
post '/v0/system/config/default_domain' do
  cparams =  Utils::Params.assemble_params(params, [], [:default_domain])
  default_domain = cparams[:default_domain]
    r = engines_api.set_default_domain(default_domain)
    if r
      status(202)
      return r.to_json
    end
  log_error(request, r,  cparams)
   status(404)
end
# @!group /system/config/
# @method get_default_site
# @overload get '/v0/system/config/default_site'
# get the default system domain
# 
# @return [String|EnginesError]
get '/v0/system/config/default_site' do
  default_site = engines_api.get_default_site
  unless default_site.is_a?(EnginesError)
    status(202)
    return default_site.to_json
  else
    log_error(request, default_site)
    status(404)
  end
end
# @method set_default_site 
# @overload post '/v0/system/config/default_site'
# set the default site
#  :default_site
# @return  [true|EnginesError]
post '/v0/system/config/default_site' do
  cparams =  Utils::Params.assemble_params(params, [], [:default_site])
  default_site = cparams[:default_site]
    r = engines_api.set_default_site(default_site)
  if r
       status(202)
       return r.to_json
     end
  log_error(request, r, cparams)
  return status(404)
end
# @method set_hostname
# @overload post '/v0/system/config/hostname'
# set the hostname
#  :host_name
# @return [true|EnginesError]
post '/v0/system/config/hostname' do
  cparams =  Utils::Params.assemble_params(params, [], [:host_name])
  hostname = cparams[:host_name]
    r = engines_api.set_hostname(hostname)
  if r
       status(202)
       return r.to_json
     end
  log_error(request, r, cparams)
  return status(404)
end
# @method get_hostname
# @overload get '/v0/system/config/hostname'
# get the hostname
# @return [String|EnginesError]
get '/v0/system/config/hostname' do
  hostname = engines_api.system_hostname
  unless hostname.is_a?(EnginesError)
    status(202)
    return hostname.to_json
  else
    log_error(request, hostname)
    return status(404)
  end
end
# @method enable_remote_exception_logging
# @overload post '/v0/system/config/remote_exception_logging/enable'
# enable remote_exception_logging setting
# @return [true|EnginesError]
post '/v0/system/config/remote_exception_logging/enable' do
  r = engines_api.enable_remote_exception_logging
  unless r.is_a?(EnginesError)
    status(202)
    return r.to_json
  else
    log_error(request, r)
    return status(404)
  end
end
# @method disable_remote_exception_logging
# @overload post '/v0/system/config/remote_exception_logging/disable'
# disable remote_exception_logging setting
# @return [true|EnginesError]
post '/v0/system/config/remote_exception_logging/disable' do
  r = engines_api.disable_remote_exception_logging
  unless r.is_a?(EnginesError)
     status(202)
     return r.to_json
  else
    log_error(request, r)
    return status(404)
  end
end
# @method get_remote_exception_logging
# @overload get '/v0/system/config/remote_exception_logging'
# get the remote_exception_logging setting
# @return ['true'|'false'|EnginesError]
get '/v0/system/config/remote_exception_logging' do
  remote_exception_logging = SystemStatus.is_remote_exception_logging?
  status(202)
  return remote_exception_logging.to_json
  #status(202)
  #  else
  #    log_error('remote_exception_logging')
  #    return  status(404)
  #  end
end
# @!endgroup
