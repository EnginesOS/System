require '/opt/engines/lib/ruby/api/system/errors_api.rb'
class Container < ErrorsApi
  
  def initialize(mem, name, host, domain, image, e_ports, vols, environs) # for test only
    @memory = mem
    @container_name = name
    @hostname = host
    @domain_name = domain
    @image = image
    @eports = e_ports
    @volumes = vols
    @environments = environs
    @container_id = -1
    @docker_info = nil
  end
  
  attr_reader :docker_info,\
               :container_id,\
               :memory,\
               :container_name,\
               :hostname,\
               :domain_name,\
               :image,\
               :eports,\
               :volumes,\
               :environments
  attr_accessor :last_error
  
  def update_memory(new_memory)
    @memory = new_memory
  end
         
  def fqdn
    return 'N/A' if @domain_name.nil? == true
    return @hostname.to_s + '.' + @domain_name.to_s
  end
   
   def set_hostname_details(host_name, domain_name)
     @hostname = host_name
     @domain_name = domain_name
     return true
   end
   
  
end
