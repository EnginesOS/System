# @!group /system/keys/user
# @method generate_user_key
# @overload get '/v0/system/keys/user/:user_name/generate'
# Generate a new ssh access key for :user_name (only valid user is 'engines')
# replaced the existing ssh key
# returns the private key
# @return [String]
# test cd /opt/engines/tests/engines_api/system/keys/user/; make generate
get '/v0/system/keys/user/:user_name/generate' do
  begin
    return_text(engines_api.generate_engines_user_ssh_key)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @!group /system/keys/user
# @method upload_user_key
# @overload post '/v0/system/keys/user/:user_name'
# Upload new ssh access key for :user_name (only valid user is 'engines')
# replaced the existing ssh public key
# @param :public_key
# @return [true]
# test cd /opt/engines/tests/engines_api/system/keys/user/; make upload
post '/v0/system/keys/user/:user_name' do
  begin
    params.merge!(post_params(request))
    cparams = assemble_params(params, [:user_name], :public_key)
    update_key = cparams[:public_key]
    return_text(engines_api.update_public_key(update_key))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_user_key
# @overload get '/v0/system/keys/user/:user_name'
# return public access key for :user_name (only valid user is 'engines')
# @return [String]
# test cd /opt/engines/tests/engines_api/system/keys/user/; make public
get '/v0/system/keys/user/:user_name' do
  begin
    return_text(engines_api.get_public_key)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
