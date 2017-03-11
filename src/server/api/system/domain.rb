# @!group /system/domains/
# @method get_domain_name
# @overload get '/v0/system/domains/:domain_name'
# get the details for :domain_name
# @return  [Hash] :domain_name :self_hosted :internal_only
get '/v0/system/domains/:domain_name' do
  domain_name = engines_api.domain_name(params[:domain_name])

  return log_error(request, domain_name) if domain_name.is_a?(EnginesError)
  status(202)
  domain_name.to_json
end
# @method update_domain_name
# @overload post '/v0/system/domains/:domain_name'
# update the domain :domain_name
# @param :domain_name
# @param :self_hosted
# @param :internal_only optional
# @return  [true]
post '/v0/system/domains/:domain_name' do
  post_s = post_params(request)
  post_s[:domain_name] = params['domain_name']

  cparams = assemble_params(post_s, [:domain_name], :all)
  return log_error(request, cparams, post_s) if cparams.is_a?(EnginesError)
 # STDERR.puts('EDIT DOMAIN Params ' + cparams.to_s )
  r = engines_api.update_domain(cparams)
  return log_error(request, r, cparams) if r.is_a?(EnginesError)
  status(202)
  content_type 'text/plain' 
  r.to_s
end
# @!endgroup
