module EngineServiceRegistration
  
  def register_with_dns(container)
     service_hash = create_dns_service_hash(container)
     return false if service_hash.is_a?(Hash) == false
     return @engines_core.create_and_register_service(service_hash)
   end
   
  def register_with_zeroconf(container)
    service_hash = create_zeroconf_service_hash(container)
       return false if service_hash.is_a?(Hash) == false
    return @engines_core.create_and_register_service(service_hash)
  end
  
  # Called by Managed Containers
   def register_non_persistant_services(engine)
     @engines_core.register_non_persistant_services(engine)
   end
 
   # Called by Managed Containers
   def deregister_non_persistant_services(engine)
     @engines_core.deregister_non_persistant_services(engine)
   end
 
   def remove_nginx_service(container)
     service_hash = create_nginx_service_hash(container)
     @engines_core.dettach_service(service_hash)
   end
 
   def add_nginx_service(container)
     service_hash = create_nginx_service_hash(container)
     @engines_core.create_and_register_service(service_hash)
   end
   
end