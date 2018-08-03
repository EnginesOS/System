# @!group /system/system_user/

# @method get_system_system_user_settings
# @overload get '/v0/system/system_user/settings'
#
# @return Hash
#  as json
# 
get '/v0/system/system_user/settings' do
  begin
    return_json(engines_api.system_user_settings)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end


# @method set_system_system_user_settings
# @overload post '/v0/system/system_user/settings'

post '/v0/system/system_user/settings' do
  begin
    p_params = post_params(request)
    cparams = assemble_params(p_params, [], :all)
    return_boolean(engines_api.set_system_user_settings(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

post '/v0/system/system_user/password' do
  begin
    content_type 'text/plain'
    post_s = post_params(request)
    cparams = assemble_params(post_s, nil, [:new_password, :token, :current_password])
    return_boolean(engines_api.set_system_user_password(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
