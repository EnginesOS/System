post '/v0/system/domains/' do
  cparams =  Utils::Params.assemble_params(params, [], :all)
  unless @@core_api.add_domain(cparams).is_a?(FalseClass)
    return status(202)
  else
    return log_error('add_domain', params)
  end
end

delete '/v0/system/domains/:domain_name' do
  unless @@core_api.remove_domain(params[:domain_name]).is_a?(FalseClass)
    return status(202)
  else
    return log_error('remove_domain')
  end
end

get '/v0/system/domains/' do
  domains = @@core_api.list_domains()
  return log_error('list_domains') if domains.is_a?(FalseClass)
  domains.to_json
end

