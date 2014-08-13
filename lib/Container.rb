class Container
  
  
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