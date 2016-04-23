post '/v0/system/domains/' do
  cparams =  Utils::Params.assemble_params(params, [], :all)
  unless @@engines_api.add_domain(cparams).is_a?(FalseClass)
    return status(202)
  else
    return log_error(request, params)
  end
end

delete '/v0/system/domains/:domain_name' do
  unless @@engines_api.remove_domain(params[:domain_name]).is_a?(FalseClass)
    return status(202)
  else
    return log_error(request)
  end
end

get '/v0/system/domains/' do
  domains = @@engines_api.list_domains()
  return log_error(request) if domains.is_a?(FalseClass)
  domains.to_json
end

