
require "/opt/engos/lib/ruby/ManagedContainer.rb"
require 'objspace'

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
	
	def fetch_consumer name
    return @consumers.fetch(name)
	end
	
  def add_consumer(engine)
    site_hash = get_site_hash(engine)
     ret_val = add_consumer_to_service(site_hash)
  #note we add to service regardless of whether the consumer is already registered 
  #for a reason
      
     if ret_val != true
       return ret_val
     end
  
      if @consumers == nil
        @consumers = Hash.new
      end
 
#      if @consumers.has_key?(site_hash[:name]) == true     # only add if doesnt exists but allow register above
        @consumers.store(site_hash[:name], site_hash)

     # end
     save_state
     return ret_val
   end

  

  def remove_consumer engine
    site_hash = get_site_hash(engine)
      result = rm_consumer_from_service(site_hash)
     
      if @consumers !=  nil
             @consumers.delete(site_hash[:name]) { |el| "#{el} not found" }
               
          end    
      save_state
      return result
    end
    
	def create_service() 
	
    if create_container() ==true
      #FIXME need to put in another thread and start in 10secs
         Thread.new {
        #   sleep 10 #let the service come up first need a better way than wait and hope
           p "sleeping"
         sleep 120
         reregister_consumers()
         p "registered consumers"
    }
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
        #FIXME need to put in another thread and start in 10secs
              Thread.new() {
             #   sleep 10 #let the service come up first need a better way than wait and hope
                p self
                
                p "sleeping"
              sleep 120
            self.reregister_consumers() 
            p "registered consumers"
            exit
                }.join
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
   
      @consumers.each_value do |site_hash|
         add_consumer_to_service(site_hash)
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
#      puts(" managed Service") 
#      p ObjectSpace.memsize_of(managedService)
#      puts(" Hash total") 
#      p ObjectSpace.memsize_of_all(Hash)
#      puts("All managed Service") 
#      p ObjectSpace.memsize_of_all(ManagedService)
          return managedService
    rescue Exception=>e
      puts e.message + " with " + yaml.path
    end
    end
end
	