class Container
  
  def initialize(mem,name,host,domain,image,e_ports,vols,environs) #for test only
    @memory = mem
    @container_name = name
    @hostname = host
    @domain_name = domain
    @image = image
    @eports = e_ports
    @volumes = vols
    @environments = environs
    @container_id
    @docker_info=nil
  end
  
  attr_reader :docker_info,:container_id, :memory,:container_name ,:hostname,:domain_name, :image, :eports,:volumes,:environments
   
  def update_memory(new_memory)
    @memory = new_memory
  end
         
  def fqdn
    if @domain_name == nil
      return "N/A"
    end
    return @hostname + "." + @domain_name
  end
   
   def set_hostname_details(host_name,domain_name)
     @hostname = host_name
     @domain_name = domain_name
     return true
   end
   
   def get_container_memory_stats (core_api)
     return core_api.get_container_memory_stats(self)
   end
   

   
   
end