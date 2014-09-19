
require "/opt/engos/lib/ruby/ManagedContainer.rb"

class ManagedService < ManagedContainer
	@ctype="service"
	@consumers=Array.new
	
	def ctype
	  return @ctype
	end
	
	class Consumer
	  def initialize(contName,service)
	  end
	end
  def initialize(name,memory,hostname,domain_name,image,volumes,port,eports,dbs,environments,framework,runtime)                         
                 @last_error="None"                 
                 @containerName=name
                 @memory=memory
                 @hostName=hostname
                 @domainName=domain_name
                 @image=image
                 @eports=eports 
                 @environments=environments                
                 @volumes=volumes
                 
                 @port=port
                               
                 @last_result=""
                 @setState="nocontainer"
                 @databases=dbs
                 @monitored=false
                 @registerSite=false
                 @framework=framework
                 @runtime=runtime

         end
 
	def consumers
	    if @consumers == nil
	      @consumers = Array.new
	    end
    return @consumers
	end
	
	def get_site_string(engine)
	  return engine.containerName + ":" + engine.fqdn + ":" + engine.port.to_s   	  
	end
	
  def add_consumer(engine)
    site_string = get_site_string(engine)
     ret_val = add_consumer_to_service(site_string)

     if ret_val != true
       return ret_val
     end
  
      if @consumers == nil
        @consumers = Array.new
      end
 
      if @consumers.include?(site_string) == false     # only add if doesnt exists but allow register
        @consumers.push(site_string)
      end
     save_state
     return ret_val
   end

  

  def rm_consumer engine
    site_string = get_site_string(engine)
      result = rm_consumer_from_service(site_string)
     
      if(@consumers !=  nil || @consumes.length>0)
             @consumers.delete(site_string)
          end    
      save_state
      return result
    end
    
	def create_service() 
	
    if create_container() ==true
    reregister_consumers()
    save_state()
    return true
    else
      return false
    end
	 #re add consumsers   
	end
		
  def recreate
    if  destroy_container() ==true
      if   create_service()==true
            reregister_consumers()
            return true
      else
        return false        
      end
    else
      return false
    end      
    end
    
    def reregister_consumers
      @consumers.each do |site|
         add_consumer_to_service(site)
      end
           
    end
    
  def destroy 
    return false
   end
   
   def deleteimage
     return false
     #noop never do  this as need buildimage again or only for expert 
   end
  def self.from_yaml( yaml,docker_api )
    begin
          managedService = YAML::load( yaml )
          managedService.set_docker_api(docker_api)
          return managedService
    rescue Exception=>e
      puts e.message + " with " + yaml.path
    end
    end
end
	