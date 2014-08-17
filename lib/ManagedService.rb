
require "/opt/engos/lib/ruby/ManagedContainer.rb"

class ManagedService < ManagedContainer
	@ctype="service"
	@consumers=Array.new
	
	
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
 
         #  @addSiteCmd= SysConfig.addSiteCmd #="ssh -i  " + @KeyPath + "/" + @NgnixID  + " -o UserKnownHostsFile=/dev/null   rma@nginx.docker sudo sh /home/addsite.sh"
          # @rmSiteCmd=SysConfig.rmSiteCmd #"ssh -i  " + @KeyPath + "/" + @NgnixID  + " -o UserKnownHostsFile=/dev/null   rma@nginx.docker sudo sh /home/rmsite.sh"
           #@addSiteMonitorCmd=SysConfig.addSiteMonitorCmd #"ssh -i " + @KeyPath + "/" + @MonitID + "  -o UserKnownHostsFile=/dev/null   rma@monit.docker sudo sh /home/addsite.sh"
           #@rmSiteMonitorCmd=SysConfig.rmSiteMonitorCmd #"ssh -i " + @KeyPath + "/" + @MonitID + " -o UserKnownHostsFile=/dev/null   rma@monit.docker sudo sh /home/rmsite.sh"               
        #   @CidDir=SysConfig.CidDir #"/opt/mpas/run"
      
         end
  #FIXME save or save_state ?  
  def save docker_api
    docker_api.save_container self
  end
   
    def ManagedService.agetManagedServices
      return ManagedContainer.getManagedContainers("service")
    end
    
  def ManagedService.aload (name)
    return ManagedContainer.load("service",name)      
  end 
  
	def consumers
	    if @consumers == nil
	      @consumers = Array.new
	    end
    return @consumers
	end
	
	def add_consumer managedContainer
	  
	end
	

	def remove_consumer managedContainer
	
	end
	
	def create_service
	  puts ("create")
    create_container
    self.save
	 #re add consumsers   
	end
		
  def recreate
    destroy_container
    create_service
    reregister_consumers
      
    end
    
    def reregister_consumers
    end
    
  def destroy 
    
   end
   
   def deleteimage
     #noop never do  this as need buildimage again or only for expert 
   end
	
end
	