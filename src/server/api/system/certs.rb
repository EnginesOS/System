# @!group /system/certs/

# @method system_ca
# @overload get '/v0/system/certs/system_ca'
# @return [String] PEM encoded Public certificate
# test /opt/engines/tests/engines_tool/system/cert ; make system_ca
get '/v0/system/certs/system_ca' do
  begin
    return_text( engines_api.get_system_ca)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get certificate
# @overload get '/v0/system/certs/:cert_name'
# @return [String] PEM encoded Public certificate
# test /opt/engines/tests/engines_tool/system/cert ; make view
get '/v0/system/certs/:cert_name' do
  begin
    return_text(engines_api.get_cert(params[:cert_name]))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method default_certificate
# @overload get '/v0/system/certs/default'
# @return [String] PEM encoded Public certificate
# test /opt/engines/tests/engines_tool/system/cert ; make default
get '/v0/system/certs/default' do
  begin
    return_json(engines_api.get_cert('engines'))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method list_certificate
# @overload get '/v0/system/certs/'
# @return [Array] of certificate names
# certificate name is the domain name / hostname the cert was created/uploaded against
# test /opt/engines/tests/engines_tool/system/cert ; make list
get '/v0/system/certs/' do
  begin
    return_json_array(engines_api.list_certs)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method delete_certificate
# @overload delete '/v0/system/certs/:cert_name'
# delete certificate :cert_name
# @return [true]
# test /opt/engines/tests/engines_tool/system/cert ; make remove 
delete '/v0/system/certs/:cert_name' do |cert_name|
  begin
    return_text(engines_api.remove_cert(cert_name))
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
# test /opt/engines/tests/engines_tool/system/cert ; make set_default
post '/v0/system/certs/default' do
  begin
    post_s = post_params(request)
    cparams = assemble_params(post_s, [], :all)
    cparams[:set_as_default] = true
    return_text(engines_api.upload_ssl_certificate(cparams))
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
# test /opt/engines/tests/engines_tool/system/cert ; make add
post '/v0/system/certs/' do
  begin
    post_s = post_params(request)
    cparams = assemble_params(post_s, [], :all)
    return_text(engines_api.upload_ssl_certificate(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method generate_certificate
# @overload post '/v0/system/certs/generate'
# generTE certificate and key in PEM for domain_name
# test /opt/engines/tests/engines_tool/system/cert ; make generate
post '/v0/system/certs/generate' do
  begin
    p_params = post_params(request)
    cparams = assemble_params(p_params, [], :all)
    return_text(engines_api.generate_cert(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
