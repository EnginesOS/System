# @!group /system/certs/

# @method system_ca
# @overload get '/v0/system/certs/system_ca'
# @return [String] PEM encoded Public certificate
# test /opt/engines/tests/engines_api/system/cert ; make system_ca
get '/v0/system/certs/system_ca' do
  begin
    return_text(engines_api.get_system_ca)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get certificate
# @overload get '/v0/system/certs/:store/:cert_name'
# @return [String] PEM encoded Public certificate
# test /opt/engines/tests/engines_api/system/cert ; make view
get '/v0/system/certs/:store/:cert_name' do
  begin
    return_text(engines_api.get_cert(params))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method default_certificate
# @overload get '/v0/system/certs/default'
# @return [String] PEM encoded Public certificate
# test /opt/engines/tests/engines_api/system/cert ; make default
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
# test /opt/engines/tests/engines_api/system/cert ; make list
get '/v0/system/certs/' do
  begin
    return_json_array(engines_api.list_certs)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method delete_certificate
# @overload delete '/v0/system/certs/:store/:cert_name'
# delete certificate :cert_name in :store
# @return [true]
# test /opt/engines/tests/engines_api/system/cert ; make remove
delete '/v0/system/certs/:store/:cert_name' do 
  begin
    return_boolean(engines_api.remove_cert(params))
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
# test /opt/engines/tests/engines_api/system/cert ; make set_default
post '/v0/system/certs/default' do
  begin
    post_s = post_params(request)
    cparams = assemble_params(post_s, [], :all)
    cparams[:set_as_default] = true
    return_boolean(engines_api.upload_ssl_certificate(cparams))
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
# @param :install_target  service_name or default for all or not set
# @return [true]
# test /opt/engines/tests/engines_api/system/cert ; make add
post '/v0/system/certs/' do
  begin
    post_s = post_params(request)
    cparams = assemble_params(post_s, [], :all)
    return_boolean(engines_api.upload_ssl_certificate(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method generate_certificate
# @overload post '/v0/system/certs/generate'
# generTE certificate and key in PEM for domain_name
# test /opt/engines/tests/engines_api/system/cert ; make generate
post '/v0/system/certs/generate' do
  begin
    p_params = post_params(request)
    cparams = assemble_params(p_params, [], :all)
    return_boolean(engines_api.generate_cert(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method set_service_default_certificate
# @overload post '/v0/system/certs/default/:target/:store/:cert_name'
# set default cert for :target service or for all if target = default
# test
post '/v0/system/certs/default/:target/*' do
  begin
    params[:store] = File.dirname(params[:splat][0])
    params[:cert_name] = File.basename(params[:splat][0])
    params[:store] = '/' if params[:store]  == '.' || params[:store].nil?
    cparams = assemble_params(params, [:target, :store, :cert_name], nil)
    return_boolean(engines_api.set_default_cert(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

get '/v0/system/certs/service_certs' do
  begin
    return_json_array(engines_api.services_default_certs)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
