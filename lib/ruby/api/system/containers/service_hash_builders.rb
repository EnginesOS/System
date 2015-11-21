#@return [Hash] completed dns service_hash for engine on the engines.internal dns for
 #@param engine [ManagedContainer]
 def create_dns_service_hash(engine)
   service_hash = {}
   service_hash[:publisher_namespace] = 'EnginesSystem'
   service_hash[:type_path] = 'dns'
   service_hash[:persistant] = false
   service_hash[:service_container_name] = 'dns'  
   service_hash[:parent_engine] = engine.container_name
   service_hash[:container_type] = engine.ctype
   service_hash[:service_handle] = engine.container_name
   service_hash[:variables] = {}
   service_hash[:variables][:parent_engine] = engine.container_name
   if engine.ctype == 'service'
     service_hash[:variables][:hostname] = engine.hostname
   else
     service_hash[:variables][:hostname] = engine.container_name
   end
   service_hash[:variables][:name] = service_hash[:variables][:hostname]
   service_hash[:variables][:ip] = engine.get_ip_str.to_s

   return service_hash
 end
def create_zeroconf_service_hash(engine)
   service_hash = {}
   service_hash[:publisher_namespace] = 'EnginesSystem'
   service_hash[:type_path] = 'avahi'
   service_hash[:persistant] = false
   service_hash[:service_container_name] = 'avahi'  
   service_hash[:parent_engine] = engine.container_name
   service_hash[:container_type] = engine.ctype
   service_hash[:service_handle] = engine.container_name
   service_hash[:variables] = {}
   service_hash[:variables][:parent_engine] = engine.container_name
   if engine.ctype == 'service'
     service_hash[:variables][:hostname] = engine.hostname
   else
     service_hash[:variables][:hostname] = engine.container_name
   end
   service_hash[:variables][:name] = service_hash[:variables][:hostname]

   p :created_zeroconfdns_service_hash
   p service_hash
   return service_hash
 end
 #@return [Hash] completed nginx service_hash for engine on for the default website configured for
 #@param engine [ManagedContainer]
 
 def create_nginx_service_hash(engine)
   proto =  'http_https'
   case engine.protocol
   when :https_only
     proto = 'https'
   when :http_and_https
     proto = 'http_https'
   when :http_only
     proto = 'http'
   end
   #
   #    p :proto
   #    p proto
   service_hash = {}
   service_hash[:persistant] = false
   service_hash[:service_container_name] = 'nginx'
   service_hash[:type_path] = 'nginx'
   service_hash[:publisher_namespace] = 'EnginesSystem'
   service_hash[:service_handle] =  engine.fqdn          
   service_hash[:parent_engine] = engine.container_name
   service_hash[:container_type] = engine.ctype
   service_hash[:variables] = {}
   service_hash[:variables][:parent_engine] = engine.container_name
   service_hash[:variables][:name] = engine.container_name  
   service_hash[:variables][:fqdn] = engine.fqdn
   service_hash[:variables][:port] = engine.web_port.to_s
   service_hash[:variables][:proto] = proto
   SystemUtils.debug_output('create nginx Hash',service_hash)
   return service_hash
 end
 