module DomainOperations
  
  def add_domain(params)
     dns_api = DNSApi.new(service_manager)
     return true if dns_api.add_domain(params)
     log_error_mesg(dns_api.last_error, params)
   end
 
   def update_domain(params)
     dns_api = DNSApi.new(service_manager)
     return true if dns_api.update_domain(params)
     log_error_mesg(dns_api.last_error, params)
   end
 
   def remove_domain(params)
     dns_api = DNSApi.new(service_manager)
     return true if dns_api.remove_domain(params)
     log_error_mesg(dns_api.last_error, params)
   end
   
 
   
end