class Container
  
  def initialize(mem,name,host,domain,image,e_ports,vols,environs) #for test only
    @memory = mem
    @containerName = name
    @hostName = host
    @domainName = domain
    @image = image
    @eports = e_ports
    @volumes = vols
    @environments = environs
    @container_id
  end
  
  attr_reader :container_id, :memory,:containerName ,:hostName,:domainName, :image, :eports,:volumes,:environments
   
  def update_memory(new_memory)
    @memory = new_memory
  end
         
  def fqdn
    if @domainName == nil
      return "N/A"
    end
    return @hostName + "." + @domainName
  end
   
   def set_hostname_details(host_name,domain_name)
     @hostName = host_name
     @domainName = domain_name
     return true
   end
   
   def get_container_memory_stats (core_api)
     return core_api.get_container_memory_stats(self)
   end
   

   
   
end