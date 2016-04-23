get '/v0/system/config/default_domain' do
  default_domain = @@engines_api.get_default_domain
  unless default_domain.is_a?(FalseClass)
    return default_domain.to_json
  else
    log_error('get default domain')
    status(404)
  end
end

post '/v0/system/config/default_domain' do
  cparams =  Utils::Params.assemble_params(params, [], [:default_domain])
  default_domain = cparams[:default_domain]
  return status(202) if @@engines_api.set_default_domain(default_domain)
  log_error('default_domain', params)
  return status(404)
end

get '/v0/system/config/default_site' do
  default_site = @@engines_api.get_default_site
  unless default_site.is_a?(FalseClass)
    return default_site.to_json
  else
    log_error('get default site')
    status(404)
  end
end

post '/v0/system/config/default_site' do
  cparams =  Utils::Params.assemble_params(params, [], [:default_site])
  default_domain = cparams[:default_site]
  return status(202) if @@engines_api.set_default_site(default_site)
  log_error('default_site', params)
  return status(404)
end

post '/v0/system/config/hostname' do
  cparams =  Utils::Params.assemble_params(params, [], [:host_name])
  hostname = cparams[:host_name]
  return status(202) if @@engines_api.set_hostname(hostname)
  log_error('hostname', params)
  return status(404)
end

get '/v0/system/config/hostname' do
  hostname = @@engines_api.system_hostname
  unless hostname.is_a?(FalseClass)
    return hostname.to_json
  else
    log_error('hostname')
    return  status(404)
  end
end

post '/v0/system/config/remote_exception_logging/enable' do

  unless @@engines_api.enable_remote_exception_logging.is_a?(FalseClass)
    return status(202)
  else
    log_error('remote_exception_logging', params)
    return status(404)
  end
end

post '/v0/system/config/remote_exception_logging/disable' do

  unless @@engines_api.disable_remote_exception_logging.is_a?(FalseClass)
    return status(202)
  else
    log_error('remote_exception_logging', params)
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

