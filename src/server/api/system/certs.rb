# @!group /system/certs/

# @method system_ca
# @overload get '/v0/system/certs/system_ca'
# @return [String] PEM encoded Public certificate

get '/v0/system/certs/system_ca' do
  begin
    system_ca = engines_api.get_system_ca
    return_text(system_ca)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get certificate
# @overload get '/v0/system/certs/:cert_name'
# @return [String] PEM encoded Public certificate
get '/v0/system/certs/:cert_name' do
  begin
    cert = engines_api.get_cert(params[:cert_name])
    return_text(cert)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method default_certificate
# @overload get '/v0/system/certs/default'
# @return [String] PEM encoded Public certificate
get '/v0/system/certs/default' do
  begin
    cert = engines_api.get_cert('engines')
    return_json(cert)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method list_certificate
# @overload get '/v0/system/certs/'
# @return [Array] of certificate names
# certificate name is the domain name / hostname the cert was created/uploaded against
get '/v0/system/certs/' do
  begin
    certs = engines_api.list_certs
    return_json_array(certs)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method delete_certificate
# @overload delete '/v0/system/certs/:cert_name'
# delete certificate :cert_name
# @return [true]
delete '/v0/system/certs/:cert_name' do |cert_name|
  begin
    r = engines_api.remove_cert(cert_name)
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
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
  begin
    post_s = post_params(request)
    cparams = assemble_params(post_s, [], :all)
    cparams[:set_as_default] = true
    r = engines_api.upload_ssl_certificate(cparams)
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
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
  begin
    post_s = post_params(request)
    cparams = assemble_params(post_s, [], :all)
    r = engines_api.upload_ssl_certificate(cparams)
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method generate_certificate
# @overload post '/v0/system/certs/generate'
# generTE certificate and key in PEM for domain_name

post '/v0/system/certs/generate' do
  begin
    p_params = post_params(request)
    cparams = assemble_params(p_params, [], :all)
    r = engines_api.generate_cert(cparams)
    return_text(r)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
