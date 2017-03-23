# @!group /system/domains/
# @method add_domain_name
# @overload post '/v0/system/domains/'
# add the domain :domain_name
# @param :domain_name
# @param :self_hosted
# @param :internal_only optional
# @return  [true]
post '/v0/system/domains/' do
  begin
    p_params = post_params(request)
    cparams = assemble_params(p_params, [], :all)
    r = engines_api.add_domain(cparams)
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method delete_domain_name
# @overload delete '/v0/system/domains/:domain_name'
# delete the domain name :domain_name
# @return  [true]
delete '/v0/system/domains/:domain_name' do
  begin
    r = engines_api.remove_domain(params[:domain_name])
    return_text(r)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @method list_domain_names
# @overload get '/v0/system/domains/'
#  list the domains
# @return  [Array] Array of [Hash] :domain_name :self_hosted :internal_only
get '/v0/system/domains/' do
  begin
    domains = engines_api.list_domains
    return_json_array(domains)
  rescue StandardError => e
    log_error(request, e)
  end
end
# @!endgroup
