# @!group /system/repo/keys


# @method get_system_public_key
# @overload get '/v0/system/key/system'
# return public key for the engines system
# @return [String]
# test make public
get '/v0/system/keys/repo' do
  begin
    return_json(engines_api.get_repo_keys_names)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
#
## @method set_ms_public_key
## params[:public_key]
## @overload post '/v0/system/key/mothership'
## set public key for the engines mothership
## @return boolean
#
#post '/v0/system/key/mothership' do
#  begin
#    params.merge!(post_params(request))
#    cparams = assemble_params(params, :public_key)     
#    return_boolean(engines_api.set_ms_public_key(cparams[:public_key]))
#  rescue StandardError => e
#    send_encoded_exception(request: request, exception: e)
#  end
#end
#
#
## @method get_ms_public_key
## @overload get '/v0/system/key/mothership'
## return public key for the engines mothership
## @return [String]
## throws warningException if no public key for the engines mother ship
## test make public
#get '/v0/system/key/mothership' do
#  begin
#    return_text(engines_api.get_ms_public_key)
#  rescue StandardError => e
#    send_encoded_exception(request: request, exception: e)
#  end
#end
## @!endg
#
## @!group /system/keys/user
## @method generate_user_key
## @overload get '/v0/system/keys/user/:user_name/generate'
## Generate a new ssh access key for :user_name (only valid user is 'engines')
## replaced the existing ssh key
## returns the private key
## @return [String]
## test cd /opt/engines/tests/engines_api/system/keys/user/; make generate
#get '/v0/system/keys/user/:user_name/generate' do
#  begin
#    return_text(engines_api.generate_engines_user_ssh_key)
#  rescue StandardError => e
#    send_encoded_exception(request: request, exception: e)
#  end
#end
## @method upload_user_key
## @overload post '/v0/system/keys/user/:user_name'
## Upload new ssh access key for :user_name (only valid user is 'engines')
## replaced the existing ssh public key
## @param :public_key
## @return [true]
## test cd /opt/engines/tests/engines_api/system/keys/user/; make upload
#post '/v0/system/keys/user/:user_name' do
#  begin
#    params.merge!(post_params(request))
#    cparams = assemble_params(params, [:user_name], :public_key)
#    return_text(engines_api.update_user_public_key(cparams[:public_key]))
#  rescue StandardError => e
#    send_encoded_exception(request: request, exception: e)
#  end
#end
#
## @method get_user_key
## @overload get '/v0/system/keys/user/:user_name'
## return public access key for :user_name (only valid user is 'engines')
## @return [String]
## test cd /opt/engines/tests/engines_api/system/keys/user/; make public
#get '/v0/system/keys/user/:user_name' do
#  begin
#    return_text(engines_api.get_user_public_key)
#  rescue StandardError => e
#    send_encoded_exception(request: request, exception: e)
#  end
#end
# @!endgroup
