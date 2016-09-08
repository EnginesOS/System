# @!group /system/certs/

# @method system_ca
# @overload get '/v0/system/certs/system_ca'
# @return [String] PEM encoded Public certificate

get '/v0/system/certs/system_ca' do
  system_ca = engines_api.get_system_ca
  return log_error(request, system_ca) if system_ca.is_a?(EnginesError)
  content_type 'text/plain'
  system_ca.to_to
end

# @method get certificate
# @overload get '/v0/system/certs/:cert_name'
# @return [String] PEM encoded Public certificate
get '/v0/system/certs/:cert_name' do
  cert = engines_api.get_cert(params[:cert_name])
  return log_error(request, cert) if cert.is_a?(EnginesError)
  content_type 'text/plain'
  cert.to_s
end

# @method default_certificate
# @overload get '/v0/system/certs/default'
# @return [String] PEM encoded Public certificate
get '/v0/system/certs/default' do
  cert = engines_api.get_cert('engines')
  return log_error(request, cert) if cert.is_a?(EnginesError)
  content_type 'text/plain'
  cert.to_s
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
# delete certificate :cert_name
# @return [true]
delete '/v0/system/certs/:cert_name' do |cert_name|
  r = engines_api.remove_cert(cert_name)
  return log_error(request, r) if r.is_a?(EnginesError)
  status(202)
  content_type 'text/plain'
  r.to_s
end

# @method upload_default_certificate
# @overload post '/v0/system/certs/default'
# import certificate and key in PEM for domain_name and set as default
# @param  :domain_name
# @param :certificate
# @param :key
# @param :password - optional
# @return [true]
post '/v0/system/certs/default' do
  post_s = post_params(request)
  cparams =  Utils::Params.assemble_params(post_s, [], :all)

  cparams[:set_as_default] = true
  r = engines_api.upload_ssl_certificate(cparams)
  return log_error(request, r, cparams) if r.is_a?(EnginesError)
  status(202)
  content_type 'text/plain'
  r.to_s
end
# @method upload_certificate
# @overload post '/v0/system/certs/'
# import certificate and key in PEM for domain_name
# @param  :domain_name
# @param :certificate
# @param :key
# @param :password - optional
# @return [true]
post '/v0/system/certs/' do
  post_s = post_params(request)
  cparams =  Utils::Params.assemble_params(post_s, [], :all)
  r = engines_api.upload_ssl_certificate(cparams)
  return  log_error(request, r, cparams) if r.is_a?(EnginesError)
  status(202)
  content_type 'text/plain'
  r.to_s
end

# @!endgroup