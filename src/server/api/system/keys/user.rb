get '/v0/system/keys/user/:user_name/generate' do
  generated_key = @@engines_api.generate_engines_user_ssh_key
  unless generated_key.is_a?(FalseClass)
    return generated_key.to_json
  else
    return log_error(request, generated_key)
  end
end

post '/v0/system/keys/user/:user_name' do
  cparams =  Utils::Params.assemble_params(params, [:user_name],  :public_key) 
  update_key = cparams[:public_key] #symbolize_keys(params)
    r = @@engines_api.update_public_key(update_key)
  unless r.is_a?(FalseClass)
    return status(202)
  else
    return log_error(request, r, cparams)
  end
end

get '/v0/system/keys/user/:user_name' do
  public_key = @@engines_api.get_public_key
  unless public_key.is_a?(FalseClass)
    return public_key.to_json
  else
    return log_error(request, public_key)
  end
end