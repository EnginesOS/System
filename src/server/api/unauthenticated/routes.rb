# @!group /unauthorized
# @method get_mgmt_url
# @overload get '/v0/system/bootstrap/mgmt_url'
# get the system mgmt url
# 
# @return [String] 
get '/v0/unauthenticated/bootstrap/mgmt/url' do
  engines_api.get_default_domain
end

# @method get_mgmt_status
# @overload get '/v0/system/bootstrap/mgmt_url'
# get the system mgmt container status
# 
# @return [String]  starting|running|stopped|creating|upgrading
get '/v0/unauthenticated/bootstrap/mgmt/status' do
  
  # starting
  # running
  
end