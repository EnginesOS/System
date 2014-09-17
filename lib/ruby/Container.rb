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
  
  def container_id
    return @container_id
  end
  def set_container_id id
    @container_id = id
  end
  def memory
     return @memory
   end
  
   def containerName
           return @containerName
  end
  
  def hostName
    return @hostName
  end
  
  def domainName
    return @domainName
  end
         
  def fqdn
    if @domainName == nil
      return "N/A"
    end
    return @hostName + "." + @domainName
  end
  
  def image
    return @image
  end
  
  def eports
    return @eports
  end
  
  def volumes
     return @volumes
   end
   
   def environments
     return @environments
   end
end