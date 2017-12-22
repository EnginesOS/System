def get_dns_search
   search = []
   search.push(SystemConfig.internal_domain)
   search
 end
 require '/opt/engines/lib/ruby/api/system/system_status.rb'

 def get_dns_servers
   servers = []
   servers.push( SystemStatus.get_docker_ip)
   servers
 end
 
def container_get_dns_servers(container)
   get_dns_servers
 end

 def container_dns_search(container)
   get_dns_search
 end
def hostname(container)
  #  return nil if container.on_host_net? == true
  if container.hostname.nil?
    container.container_name
  else
    container.hostname
  end
end

def container_domain_name(container)
  SystemConfig.internal_domain# if container.on_host_net? == false
end

