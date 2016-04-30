post '/v0/system/domains/' do
  cparams =  Utils::Params.assemble_params(params, [], :all)
    r = @@engines_api.add_domain(cparams)
  unless  r.is_a?(FalseClass)
    return status(202)
  else
    return log_error(request, r, params)
  end
end

delete '/v0/system/domains/:domain_name' do
  r = @@engines_api.remove_domain(params[:domain_name])
  unless r.is_a?(FalseClass)
    return status(202)
  else
    return log_error(request, r)
  end
end

get '/v0/system/domains/' do
  domains = @@engines_api.list_domains()
  return log_error(request, domains) if domains.is_a?(FalseClass)
  domains.to_json
end

