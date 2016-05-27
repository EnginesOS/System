# @!group /system/domains/
# @method get_domain_name
# @overload get '/v0/system/domains/get_domain_name'
# get the details for :domain_name
# @return  [Hash]
get '/v0/system/domains/:domain_name' do
  domain_name = engines_api.domain_name(params[:domain_name])
  unless domain_name.is_a?(EnginesError)
    status(202)
    return domain_name.to_json
  else
    return log_error(request, domain_name)
  end
end
# @method add_domain_name
# @overload post '/v0/system/domains/get_domain_name'
# add the domain :domain_name
#  :domain_name :self_hosted 
#  :internal_only (optional)
# @return  [true]
post '/v0/system/domains/:domain_name' do
  cparams =  Utils::Params.assemble_params(params, [:domain_name], :all)
  r = engines_api.update_domain(cparams)
  unless r.is_a?(EnginesError)
    status(202)
    return r.to_json
  else
    return log_error(request, r, cparams)
  end
end
# @!endgroup
