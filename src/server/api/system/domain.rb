get '/v0/system/domain/:domain_name' do
  domain_name = @@core_api.domain_name(params[:domain_name])
  unless domain_name.is_a?(FalseClass)
    return domain_name.to_json
  else
    return log_error('domain_name')
  end
end

post '/v0/system/domain/:domain_name' do
  cparams =  Utils::Params.assemble_params(params, [:domain_name], :all)
  unless @@core_api.update_domain(cparams).is_a?(FalseClass)
    return status(202)
  else
    return log_error('update_domain', cparams)
  end
end

