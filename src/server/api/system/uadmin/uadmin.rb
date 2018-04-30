def token_owner
  tok_params = $user_tokens[request.env['HTTP_ACCESS_TOKEN']]
  if tok_params.nil?
    'sysadmin'
  else
    tok_params[:user_name]
  end
end
post '/v0/system/uadmin/dn_lookup' do
  begin
     require_relative 'uadmin_verbs.rb'
     STDERR.puts(' post dn_lookup')
     params[:token_owner] = nil
     p_params = post_params(request)
     STDERR.puts('I got Posted ' + p_params.to_s)
     uadmin_response(uadmin_post(params[:splat][0], params, p_params))
   rescue StandardError => e
     send_encoded_exception(request: request, exception: e)
   end
  end
  
get '/v0/system/uadmin/*' do
  begin
    STDERR.puts(' Get')
    require_relative 'uadmin_verbs.rb'
    STDERR.puts(' Getting')
    params[:token_owner] = token_owner
    STDERR.puts('I got ' + params.to_s)
    p_params = post_params(request)
    uadmin_response(uadmin_get(params[:splat][0], params, p_params))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

put '/v0/system/uadmin/*' do
  begin
    require_relative 'uadmin_verbs.rb'
    p_params = post_params(request)
    params[:token_owner] = token_owner
    STDERR.puts(' Put' + params.to_s)
    uadmin_response(uadmin_put(params[:splat][0], params, p_params))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

post '/v0/system/uadmin/*' do
  begin
    require_relative 'uadmin_verbs.rb'
    p_params = post_params(request)
    params[:token_owner] = token_owner
    STDERR.puts(' Post' + params.to_s)
    uadmin_response(uadmin_post(params[:splat][0], params, p_params))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

delete '/v0/system/uadmin/*' do
  begin
    require_relative 'uadmin_verbs.rb'
    p_params = post_params(request)
    params[:token_owner] = token_owner
    uadmin_response(uadmin_del(params[:splat][0], params, p_params))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end