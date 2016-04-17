
get '/v0/system/domain/:id' do
  domain_name = @@core_api.domain_name(params[:id])
  unless domain_name.is_a?(FalseClass)
    return domain_name.to_json
  else
    return log_error('domain_name')
  end
end

post '/v0/system/domain/:id' do
  unless @@core_api.update_domain(params).is_a?(FalseClass)
    return status(202)
  else
    return log_error('update_domain', params)
  end
end  


