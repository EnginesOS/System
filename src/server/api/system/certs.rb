#/system/certs/system_ca Get
#/system/certs/ P
#/system/certs/ Del
#/system/certs/ List
#/system/cert/cert_name Get

get '/v0/system/cert/system_ca' do
  system_ca = @@engines_api.get_system_ca
  unless system_ca.is_a?(EnginesError)
    return system_ca.to_json
  else
    return log_error(request, system_ca)
  end
end

get '/v0/system/cert/default' do
  cert = @@engines_api.get_cert('engines')
  unless cert.is_a?(EnginesError)
    return cert.to_json
  else
    return log_error(request, cert)
  end
end

get '/v0/system/certs/' do
  certs = @@engines_api.list_certs
  return log_error('list certs', certs, params) if certs.is_a?(EnginesError)
  certs.to_json
end

delete '/v0/system/certs/:cert_name' do
  r = @@engines_api.remove_cert(params[:cert_name])
  unless r.is_a?(EnginesError)
     status(202)
     return r.to_json
  else
    return log_error(request, r)
  end
end

get '/v0/system/cert/:cert_name' do
  if params[:cert_name] == 'system_ca'
    cert = @@engines_api.get_system_ca
  else
    cert = @@engines_api.get_cert(params[:cert_name])
  end
  unless cert.is_a?(EnginesError)
    return cert.to_json
  else
    return log_error(request, cert)
  end
end
post '/v0/system/certs/default' do
  cparams =  Utils::Params.assemble_params(params, [], :all)
 
  cparams[:set_as_default] = true
    r = @@engines_api.upload_ssl_certificate(cparams)
  if r
       status(202)
       return r.to_json
     end
  log_error(request, r, cparams)
  return status(404)
end

post '/v0/system/certs/' do
  cparams =  Utils::Params.assemble_params(params, [], :all)
    r = @@engines_api.upload_ssl_certificate(cparams)
  if r
       status(202)
       return r.to_json
     end
  log_error(request, r, cparams)
  return status(404)
end

