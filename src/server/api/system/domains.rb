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

  cparams =  Utils::Params.assemble_params(p_params, [], :all)
  return log_error(request, cparams, p_params) if cparams.is_a?(EnginesError)
  r = engines_api.add_domain(cparams)
  return log_error(request, r, params) if  r.is_a?(EnginesError)
  status(202)
  content_type 'text/plain' 
  r.to_s
end
# @method delete_domain_name
# @overload delete '/v0/system/domains/:domain_name'
# delete the domain name :domain_name
# @return  [true]
delete '/v0/system/domains/:domain_name' do
  r = engines_api.remove_domain(params[:domain_name])
  return log_error(request, r) if r.is_a?(EnginesError)
  status(202)
  content_type 'text/plain' 
  r.to_s
end
# @method list_domain_names
# @overload get '/v0/system/domains/'
#  list the domains
# @return  [Array] Array of [Hash] :domain_name :self_hosted :internal_only
get '/v0/system/domains/' do
  domains = engines_api.list_domains()
  return log_error(request, domains) if domains.is_a?(EnginesError)
  status(202)
  domains.to_json
end
# @!endgroup
