get '/v0/system/uadmin/*' do
  begin
    STDERR.puts(' Get')
    require_relative 'uadmin_verbs.rb'
    STDERR.puts(' Getting')
    STDERR.puts('I got ' + params.to_s) 
    uadmin_response(uadmin_get(params[:splat][0], params))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

put '/v0/system/uadmin/*' do
  begin
    require_relative 'uadmin_verbs.rb'
    STDERR.puts(' Put' + params.to_s)
    uadmin_response(uadmin_put(params[:splat][0], request.env['rack.input'], params))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

post '/v0/system/uadmin/*' do
 # params = post_params(request)
  STDERR.puts(' Post' + params.to_s)
  begin
    require_relative 'uadmin_verbs.rb'   
  uadmin_response(uadmin_post(params[:splat][0], request.env['rack.input'], params))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

delete '/v0/system/uadmin/*' do
  begin
    require_relative 'uadmin_verbs.rb'
  uadmin_response(uadmin_del(params[:splat][0], params))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end