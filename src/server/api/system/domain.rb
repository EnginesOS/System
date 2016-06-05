# @!group /system/domains/
# @method get_domain_name
# @overload get '/v0/system/domains/:domain_name'
# get the details for :domain_name
# @return  [Hash] :domain_name :self_hosted :internal_only
get '/v0/system/domains/:domain_name' do
  domain_name = engines_api.domain_name(params[:domain_name])
   
  unless domain_name.is_a?(EnginesError)
    status(202)
    return domain_name.to_json
  else
    return log_error(request, domain_name)
  end
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
p 'update domain ' + post_s
  cparams =  Utils::Params.assemble_params(post_s, [:domain_name], :all)
  r = engines_api.update_domain(cparams)
  unless r.is_a?(EnginesError)
    status(202)
    return r.to_json
  else
    return log_error(request, r, cparams)
  end
end
# @!endgroup
