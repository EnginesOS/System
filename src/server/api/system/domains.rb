# @!group /system/domains/
# @method add_domain_name
# @overload post '/v0/system/domains/'
# add the domain :domain_name
# @param :domain_name
# @param :self_hosted
# @param :internal_only optional
# @return  [true]
# test cd /opt/engines/tests/engines_api/system/domains ; make add
post '/v0/system/domains/' do
  begin
    p_params = post_params(request)
    cparams = assemble_params(p_params, [], :all)
    return_text(engines_api.add_domain(cparams))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method delete_domain_name
# @overload delete '/v0/system/domains/:domain_name'
# delete the domain name :domain_name
# @return  [true]
# test cd /opt/engines/tests/engines_api/system/domains ; make remove 
delete '/v0/system/domains/:domain_name' do
  begin
    return_text(engines_api.remove_domain(params[:domain_name]))
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end

# @method list_domain_names
# @overload get '/v0/system/domains/'
#  list the domains
# @return  [Array] Array of [Hash] :domain_name :self_hosted :internal_only
# test cd /opt/engines/tests/engines_api/system/domains ; make list
get '/v0/system/domains/' do
  begin
    return_json_array(engines_api.list_domains)
  rescue StandardError => e
    send_encoded_exception(request: request, exception: e)
  end
end
# @!endgroup
