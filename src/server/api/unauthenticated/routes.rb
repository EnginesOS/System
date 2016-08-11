# @!group /unauthorized
# @method get_mgmt_url
# @overload get '/v0/system/bootstrap/mgmt_url'
# get the system mgmt url
# 
# @return [String] 
get '/v0/unauthenticated/bootstrap/mgmt/url' do
 'https://' + engines_api.get_default_domain.to_s + '/:10443'
end

# @method get_mgmt_status
# @overload get '/v0/unauthenticated/bootstrap/mgmt/status'
# get the system mgmt container status
# 
# @return [String]  starting|running|stopped|creating|upgrading
get '/v0/unauthenticated/bootstrap/mgmt/status' do
  engine = get_service('mgmt')
   return log_error(request, engine, params) if engine.is_a?(EnginesError)
   engine.status.to_json
end
  # starting
  # running
  # @method get_mgmt_state
  # @overload get '/v0/unauthenticated/bootstrap/mgmt/state'
  # get the system mgmt container state
  # 
  # @return [String]  starting|running|stopped|creating|upgrading
  get '/v0/unauthenticated/bootstrap/mgmt/state' do
    engine = get_service('mgmt')
     return log_error(request, engine, params) if engine.is_a?(EnginesError)
     engine.read_state.to_json
    # starting
    # running
end
# starting
# running
# @method set_first_run_complete
# @overload post '/v0/unauthenticated/bootstrap/first_run/complete'
# tell first run wizard you are complete and ready to start mgmt
# 
# @return [Boolean]  
post '/v0/unauthenticated/bootstrap/first_run/complete' do

  engines_api.first_run_complete
  
end
