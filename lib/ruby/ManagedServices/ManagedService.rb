
require "/opt/engos/lib/ruby/ManagedContainer.rb"

class ManagedService < ManagedContainer
	@ctype="service"
	@consumers=Hash.new
	
	def ctype
	  return @ctype
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
	      @consumers = Hash.new
	    end
    return @consumers
	end
	
	def get_site_hash(engine)
	  site_hash = Hash.new()
	  site_hash[:name]=engine.containerName
    site_hash[:container_type]=engine.ctype
    site_hash[:fqdn]=engine.fqdn
    site_hash[:port]=engine.port.to_s
	  return site_hash
	    
	end
	
  def add_consumer(engine)
    site_hash = get_site_hash(engine)
     ret_val = add_consumer_to_service(site_hash)
  
     if ret_val != true
       return ret_val
     end
  
      if @consumers == nil
        @consumers = Hash.new
      end
 
      if @consumers.include?(site_hash[:name]) == false     # only add if doesnt exists but allow register
        @consumers.store(site_hash[:name], site_hash)
      end
     save_state
     return ret_val
   end

  

  def remove_consumer engine
    site_hash = get_site_hash(engine)
      result = rm_consumer_from_service(site_hash)
     
      if @consumers !=  nil
             @consumers.delete(site_hash[:name])
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
       if @consumers == nil
         return
       end
       #FIXME need to put in another thread and start in 10secs
       Thread.new {
         sleep 10
       
      @consumers.each_value do |site_hash|
         add_consumer_to_service(site_hash)
      end          
       } 
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
	