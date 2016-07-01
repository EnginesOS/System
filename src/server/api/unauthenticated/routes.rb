# @!group /unauthorized
# @method get_mgmt_url
# @overload get '/v0/system/bootstrap/mgmt_url'
# get the system mgmt url
# 
# @return [String] 
get '/v0/unauthenticated/bootstrap/mgmt/url' do
 ('https://' + engines_api.get_default_domain.to_s + '/:10443').to_json
end

# @method get_mgmt_status
# @overload get '/v0/system/bootstrap/mgmt_url'
# get the system mgmt container status
# 
# @return [String]  starting|running|stopped|creating|upgrading
get '/v0/unauthenticated/bootstrap/mgmt/status' do
  engine = get_engine('mgmt')
   return log_error(request, engine, params) if engine.is_a?(EnginesError)
   engine.state.to_json
  # starting
  # running
  
end