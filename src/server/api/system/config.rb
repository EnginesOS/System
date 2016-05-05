get '/v0/system/config/default_domain' do
  default_domain = @@engines_api.get_default_domain
  unless default_domain.is_a?(EnginesError)
    return default_domain.to_json
  else
    log_error(request, default_domain)
    status(404)
  end
end

post '/v0/system/config/default_domain' do
  cparams =  Utils::Params.assemble_params(params, [], [:default_domain])
  default_domain = cparams[:default_domain]
    r = @@engines_api.set_default_domain(default_domain)
  return status(202) if  r
  log_error(request, r,  cparams)
   status(404)
end

get '/v0/system/config/default_site' do
  default_site = @@engines_api.get_default_site
  unless default_site.is_a?(EnginesError)
    return default_site.to_json
  else
    log_error(request, default_site)
    status(404)
  end
end

post '/v0/system/config/default_site' do
  cparams =  Utils::Params.assemble_params(params, [], [:default_site])
  default_site = cparams[:default_site]
    r = @@engines_api.set_default_site(default_site)
  return status(202) if r
  log_error(request, r, cparams)
  return status(404)
end

post '/v0/system/config/hostname' do
  cparams =  Utils::Params.assemble_params(params, [], [:host_name])
  hostname = cparams[:host_name]
    r = @@engines_api.set_hostname(hostname)
  return status(202) if  r
  log_error(request, r, cparams)
  return status(404)
end

get '/v0/system/config/hostname' do
  hostname = @@engines_api.system_hostname
  unless hostname.is_a?(EnginesError)
    return hostname.to_json
  else
    log_error(request, hostname)
    return status(404)
  end
end

post '/v0/system/config/remote_exception_logging/enable' do
  r = @@engines_api.enable_remote_exception_logging
  unless r.is_a?(EnginesError)
    return status(202)
  else
    log_error(request, r)
    return status(404)
  end
end

post '/v0/system/config/remote_exception_logging/disable' do
  r = @@engines_api.disable_remote_exception_logging
  unless r.is_a?(EnginesError)
    return status(202)
  else
    log_error(request, r)
    return status(404)
  end
end

get '/v0/system/config/remote_exception_logging' do
  remote_exception_logging = SystemStatus.is_remote_exception_logging?
  return remote_exception_logging.to_json
  #status(202)
  #  else
  #    log_error('remote_exception_logging')
  #    return  status(404)
  #  end
end

