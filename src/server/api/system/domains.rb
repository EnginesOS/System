# @!group /system/domains/
# @method list_domain_names
# @overload get '/v0/system/domains/'
# get the details for :domain_name
# @return  Json Array|EnginesError.to_json
post '/v0/system/domains/' do
  cparams =  Utils::Params.assemble_params(params, [], :all)
    r = engines_api.add_domain(cparams)
  unless  r.is_a?(EnginesError)
    status(202)
    return r.to_json
  else
    return log_error(request, r, params)
  end
end
# @overload get '/v0/system/domains/'
# get the details for :domain_name
# @return  Json Array|EnginesError.to_json
delete '/v0/system/domains/:domain_name' do
  r = engines_api.remove_domain(params[:domain_name])
  unless r.is_a?(EnginesError)
    status(202)
    return r.to_json
  else
    return log_error(request, r)
  end
end
# @overload get '/v0/system/domains/'
#  list the domains 
# @return  Json Array|EnginesError.to_json
get '/v0/system/domains/' do
  domains = engines_api.list_domains()
  return log_error(request, domains) if domains.is_a?(EnginesError)
  status(202)
  domains.to_json
end
# @!endgroup
