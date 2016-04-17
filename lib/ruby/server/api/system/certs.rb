
  #/system/certs/system_ca Get
  #/system/certs/ P
#/system/certs/ Del
#/system/certs/ List
#/system/cert/cert_name Get


get '/v0/system/cert/system_ca' do
  system_ca = @@core_api.get_system_ca
  unless system_ca.is_a?(FalseClass)
    return system_ca.to_json
  else
    return log_error('system_ca')
  end
end

get '/v0/system/certs/' do
  certs = @@core_api.list_certs
   return log_error('list certs', params) if certs.is_a?(FalseClass)
  certs.to_json
end

delete '/v0/system/certs/:id' do
  unless @@core_api.remove_cert(params[:id]).is_a?(FalseClass)
    return status(202)
  else
    return log_error('remove_cert')
  end
end


get '/v0/system/cert/:id' do
   if params[:id] == 'system_ca'
     cert = @@core_api.get_system_ca
   else
      cert = @@core_api.get_cert(params[:id])
   end
   unless cert.is_a?(FalseClass)
    return cert.to_json
  else
    return log_error('cert')
  end
end

post '/v0/system/certs/' do
  return status(202) if @@core_api.upload_ssl_certificate(Utils.symbolize_keys(params))
  log_error('upload_ssl_certificate', params)
  return status(404)
end

