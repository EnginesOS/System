# @!group /unauthorized
# @method get_mgmt_url
# @overload get '/v0/system/bootstrap/mgmt_url'
# get the system mgmt url
# 
# @return [String] 
get '/v0/unauthenticated/bootstrap/mgmt/url' do
 'https://' + engines_api.system_hostname.to_s + '.' + engines_api.get_default_domain.to_s + ':10443'
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
# params :install_mgmt true|false defaults to true in future it will default to false
# tell first run wizard you are complete and ready to start mgmt
# 
# @return [Boolean]  
post '/v0/unauthenticated/bootstrap/first_run/complete' do
  p_params = post_params(request)
  cparams = assemble_params(p_params, [], :all)
    i = true
    i = false if cparams[:install_mgmt] == 'false' || cparams[:install_mgmt] == false
  engines_api.first_run_complete(i)  
end
# @method system_ca
# @overload get '/v0/unauthenticated/system_ca'
# @return [String] PEM encoded Public certificate

get '/v0/unauthenticated/system_ca' do
  system_ca = engines_api.get_system_ca
  return log_error(request, system_ca) if system_ca.is_a?(EnginesError)
  content_type 'text/plain'
  system_ca.to_s
end
