
get '/v0/system/domain/domain_name' do
  domain_name = @@core_api.domain_name(params)
  unless domain_name.is_a?(FalseClass)
    return domain_name.to_json
  else
    return log_error('generate_key')
  end
end

post '/v0/system/domain/domain_name' do
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
  del '/v0/system/domains/domain_name/' do
    unless @@core_api.remove_domain(params).is_a?(FalseClass)
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


