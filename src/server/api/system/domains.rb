# @!group /system/domains/
# @method add_domain_name
# @overload post '/v0/system/domains/'
# add the domain :domain_name
# @param :domain_name
# @param :self_hosted
# @param :internal_only optional
# @return  [true]
post '/v0/system/domains/' do
  p_params = post_params(request)

  cparams = assemble_params(p_params, [], :all)
  return log_error(request, cparams, p_params) if cparams.is_a?(EnginesError)
  
 # STDERR.puts('ADD DOMAIN Params ' + cparams.to_s )
  r = engines_api.add_domain(cparams)
  return log_error(request, r, params) if  r.is_a?(EnginesError)
  return_text(r)
end
# @method delete_domain_name
# @overload delete '/v0/system/domains/:domain_name'
# delete the domain name :domain_name
# @return  [true]
delete '/v0/system/domains/:domain_name' do
  r = engines_api.remove_domain(params[:domain_name])
  return log_error(request, r) if r.is_a?(EnginesError)
  return_text(r)
end
# @method list_domain_names
# @overload get '/v0/system/domains/'
#  list the domains
# @return  [Array] Array of [Hash] :domain_name :self_hosted :internal_only
get '/v0/system/domains/' do
  domains = engines_api.list_domains()
  return log_error(request, domains) if domains.is_a?(EnginesError)
  status(202)
  return_json_array(domains)
end
# @!endgroup
