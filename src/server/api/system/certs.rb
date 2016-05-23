# @!group /system/certs/
# @method system_ca
# @overload get '/v0/system/cert/system_ca'
# @return cert.to_json|EnginesError.to_json

get '/v0/system/cert/system_ca' do
  system_ca = engines_api.get_system_ca
  unless system_ca.is_a?(EnginesError)
    return system_ca.to_json
  else
    return log_error(request, system_ca)
  end
end
# @method default_certificate
# @overload get '/v0/system/cert/default'
# @return [String] PEM encoded Public certificate
get '/v0/system/cert/default' do
  cert = engines_api.get_cert('engines')
  unless cert.is_a?(EnginesError)
    return cert.to_json
  else
    return log_error(request, cert)
  end
end
# @method list_certificate
# @overload get '/v0/system/certs/'
# @return [Array] of certificate names
# certificate name is the domain name / hostname the cert was created/uploaded against
get '/v0/system/certs/' do
  certs = engines_api.list_certs
  return log_error('list certs', certs, params) if certs.is_a?(EnginesError)
  certs.to_json
end
# @method delete_certificate
# @overload delete '/v0/system/certs/:cert_name'
# @return true.to_json|EnginesError.to_json
delete '/v0/system/certs/:cert_name' do
  r = engines_api.remove_cert(params[:cert_name])
  unless r.is_a?(EnginesError)
     status(202)
     return r.to_json
  else
    return log_error(request, r)
  end
end
# @method get certificate
# @overload get '/v0/system/cert/:cert_name'
# @return [String] PEM encoded Public certificate
get '/v0/system/cert/:cert_name' do
  if params[:cert_name] == 'system_ca'
    cert = engines_api.get_system_ca
  else
    cert = engines_api.get_cert(params[:cert_name])
  end
  unless cert.is_a?(EnginesError)
    return cert.to_json
  else
    return log_error(request, cert)
  end
end
# @method upload_default_certificate
# @overload post '/v0/system/certs/default'
# import certificate and key in PEM for domain_name and set as default
#  :domain_name :certificate :key
#  optional :password
# @return true.to_json|EnginesError.to_json
post '/v0/system/certs/default' do
  cparams =  Utils::Params.assemble_params(params, [], :all)
 
  cparams[:set_as_default] = true
    r = engines_api.upload_ssl_certificate(cparams)
  if r
       status(202)
       return r.to_json
     end
  log_error(request, r, cparams)
  return status(404)
end
# @method upload_certificate 
# @overload post '/v0/system/certs/'
# import certificate and key in PEM for domain_name
#  :domain_name :certificate :key
#  optional :password
# @return true.to_json|EnginesError.to_json
post '/v0/system/certs/' do
  cparams =  Utils::Params.assemble_params(params, [], :all)
    r = engines_api.upload_ssl_certificate(cparams)
  if r
       status(202)
       return r.to_json
     end
  log_error(request, r, cparams)
  return status(404)
end

# @!endgroup