get '/v0/system/domain/:domain_name' do
  domain_name = @@engines_api.domain_name(params[:domain_name])
  unless domain_name.is_a?(EnginesError)
    return domain_name.to_json
  else
    return log_error(request, domain_name)
  end
end

post '/v0/system/domain/:domain_name' do
  cparams =  Utils::Params.assemble_params(params, [:domain_name], :all)
  r = @@engines_api.update_domain(cparams)
  unless r.is_a?(EnginesError)
    return status(202)
  else
    return log_error(request, r, cparams)
  end
end

