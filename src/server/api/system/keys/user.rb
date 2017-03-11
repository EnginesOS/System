# @!group /system/keys/user
# @method generate_user_key
# @overload get '/v0/system/keys/user/:user_name/generate'
# Generate a new ssh access key for :user_name (only valid user is 'engines')
# replaced the existing ssh key
# returns the private key
# @return [String]
get '/v0/system/keys/user/:user_name/generate' do
  generated_key = engines_api.generate_engines_user_ssh_key
  return log_error(request, generated_key) if generated_key.is_a?(EnginesError)
  content_type 'text/plain'
  generated_key.to_s
end
# @!group /system/keys/user
# @method upload_user_key
# @overload post '/v0/system/keys/user/:user_name'
# Upload new ssh access key for :user_name (only valid user is 'engines')
# replaced the existing ssh public key
# @param :public_key
# @return [true]
post '/v0/system/keys/user/:user_name' do
  content_type 'text/plain'
  p_params = post_params(request)
  params.merge!(p_params)
  cparams = assemble_params(params, [:user_name],  :public_key)
  return log_error(request, cparams, params) if cparams.is_a?(EnginesError)
  update_key = cparams[:public_key] #symbolize_keys(params)
  r = engines_api.update_public_key(update_key)
  return log_error(request, r, cparams) if r.is_a?(EnginesError)
  content_type 'text/plain'
  status(202)
  r.to_s
end

# @method get_user_key
# @overload get '/v0/system/keys/user/:user_name'
# return public access key for :user_name (only valid user is 'engines')
# @return [String]
get '/v0/system/keys/user/:user_name' do
  public_key = engines_api.get_public_key
  return log_error(request, public_key) if public_key.is_a?(EnginesError)
  status(202)
  content_type 'text/plain'
  public_key.to_s
end
# @!endgroup