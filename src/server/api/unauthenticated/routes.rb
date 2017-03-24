# @!group /unauthorized
# @method get_mgmt_url
# @overload get '/v0/system/bootstrap/mgmt_url'
# get the system mgmt url
#
# @return [String]
get '/v0/unauthenticated/bootstrap/mgmt/url' do
  begin
    'https://' + engines_api.system_hostname.to_s + '.' + engines_api.get_default_domain.to_s + ':10443'
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method get_mgmt_status
# @overload get '/v0/unauthenticated/bootstrap/mgmt/status'
# get the system mgmt container status
#
# @return [String]  starting|running|stopped|creating|upgrading
get '/v0/unauthenticated/bootstrap/mgmt/status' do
  begin
    engine = get_service('mgmt')
    return_json(engine.status)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# starting
# running
# @method get_mgmt_state
# @overload get '/v0/unauthenticated/bootstrap/mgmt/state'
# get the system mgmt container state
#
# @return [String]  starting|running|stopped|creating|upgrading
get '/v0/unauthenticated/bootstrap/mgmt/state' do
  begin
    engine = get_service('mgmt')
    return_json(engine.read_state)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
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
  begin
    p_params = post_params(request)
    cparams = assemble_params(p_params, [], :all)
    i = true
    i = false if cparams[:install_mgmt] == 'false' || cparams[:install_mgmt] == false
    return_text(engines_api.first_run_complete(i))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @method system_ca
# @overload get '/v0/unauthenticated/system_ca'
# @return [String] PEM encoded Public certificate

get '/v0/unauthenticated/system_ca' do
  begin
    system_ca = engines_api.get_system_ca
    return_text(system_ca)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
