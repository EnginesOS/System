
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

post '/v0/system/domains/' do
  unless @@core_api.add_domain(params).is_a?(FalseClass)
    return status(202)
  else
    return log_error('add_domain', params)
  end
end  
delete '/v0/system/domains/:id' do
    unless @@core_api.remove_domain(params[:id]).is_a?(FalseClass)
      return status(202)
    else
      return log_error('remove_domain')
    end
end

get '/v0/system/domains' do
   domains = @@core_api.list_domains()
   return log_error('list_domains') if domains.is_a?(FalseClass)
   domains.to_json
end


