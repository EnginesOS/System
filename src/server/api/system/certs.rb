# @!group /system/certs/

# @method system_ca
# @overload get '/v0/system/certs/system_ca'
# Returns PEM encoded Public certificate
# @return [String] 
get '/v0/system/certs/system_ca' do
  begin
    return_text(engines_api.get_system_ca)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method list_certificate
# @overload get '/v0/system/certs/'
# certificate name is the domain name / hostname the cert was created/uploaded against
# returns array of certificate names
# @return [Array] 
get '/v0/system/certs/' do
  begin
    return_json_array(engines_api.list_certs)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end



# @method default_certificate
# @overload get '/v0/system/certs/default'
 # returns PEM encoded Public certificate
# @return [String] 
get '/v0/system/certs/default' do
  begin
    return_json(engines_api.get_cert('engines'))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end



# @method delete_certificate
# @overload delete '/v0/system/certs/:store/:cert_name'
# delete certificate :cert_name in :store
# @return [true]
delete '/v0/system/certs/*' do
  begin
    p = {
         cert_name: File.basename(params[:splat][0]),
         store: File.dirname(params[:splat][0])
       }
    return_boolean(engines_api.remove_cert(p))
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
    return_boolean(engines_api.upload_ssl_certificate(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method upload_certificate
# @overload post '/v0/system/certs/'
# import certificate and key in PEM for domain_name
# @param :domain_name
# @param :certificate
# @param :key
# @param :password - optional
# @param :install_target  service_name or default for all or not set
# @return [true]
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
# generate certificate and key in PEM for domain_name
# @return [true]
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
# @return [true]
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

# @method services_default_certs
# @overload get '/v0/system/certs/service_certs'
# returns json arrays of services defautl certs
# @return [Array] 
get '/v0/system/certs/service_certs' do
  begin
    return_json_array(engines_api.services_default_certs)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get certificate
# @overload get '/v0/system/certs/store/cert_name'
# returns PEM encoded Public certificate
# @return [String] 
get '/v0/system/certs/*' do
  begin
    p = {
      cert_name: File.basename(params[:splat][0]),
      store: File.dirname(params[:splat][0])
    }
    return_text(engines_api.get_cert(p))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
