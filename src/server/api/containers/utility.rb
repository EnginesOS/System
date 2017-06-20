# @method wait_for_utility
# @overload get '/v0/containers/utility/:utility_name/wait_for/:what'
#
# @return true|false

get '/v0/containers/utility/:utility_name/wait_for/:what' do
  stream do |out|
  begin
    engine = get_utility(params[:utility_name])
   r = engine.wait_for(params[:what], 30)
    out << r.to_s unless out.closed?
    return_boolean(r)
  rescue StandardError => e
    out << false.to_s unless out.closed?
    send_encoded_exception(request: request, exception: e)
  end
  end
end
# @method wait_for_utility_delat
# @overload get '/v0/containers/engine/:engine_name/wait_for/:what/:delay'
#
# @return true|false

get '/v0/containers/utility/:utility_name/wait_for/:what/:delay' do
  stream do |out|
    begin
      engine = get_utility(params[:utility_name])
      r = engine.wait_for(params[:what], params[:delay].to_i)
       out << r.to_s unless out.closed?
      return_boolean(r)
    rescue StandardError => e
      out << false.to_s unless out.closed?
      send_encoded_exception(request: request, exception: e)
    end
  end
end

# @method clear_engine_error
# @overload get '/v0/containers/engine/:engine_name/clear
#
# @return true|false
