get '/v0/system/keys/user/:id/generate' do
  generated_key = @@core_api.generate_engines_user_ssh_key
  unless generated_key.is_a?(FalseClass)
    return generated_key.to_json
  else
    return log_error('generate_key')
  end
end

post '/v0/system/keys/user/:id' do
  update_key = params['public_key'] #symbolize_keys(params)
  unless @@core_api.update_public_key(update_key).is_a?(FalseClass)
    return status(202)
  else
    return log_error('update_public_key', params)
  end
end

get '/v0/system/keys/user/:id' do
  public_key = @@core_api.get_public_key
  unless public_key.is_a?(FalseClass)
    return public_key.to_json
  else
    return log_error('get_public_key')
  end
end