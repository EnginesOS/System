
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
 
         #  @addSiteCmd= SysConfig.addSiteCmd #="ssh -i  " + @KeyPath + "/" + @NgnixID  + " -o UserKnownHostsFile=/dev/null   rma@nginx.docker sudo sh /home/addsite.sh"
          # @rmSiteCmd=SysConfig.rmSiteCmd #"ssh -i  " + @KeyPath + "/" + @NgnixID  + " -o UserKnownHostsFile=/dev/null   rma@nginx.docker sudo sh /home/rmsite.sh"
           #@addSiteMonitorCmd=SysConfig.addSiteMonitorCmd #"ssh -i " + @KeyPath + "/" + @MonitID + "  -o UserKnownHostsFile=/dev/null   rma@monit.docker sudo sh /home/addsite.sh"
           #@rmSiteMonitorCmd=SysConfig.rmSiteMonitorCmd #"ssh -i " + @KeyPath + "/" + @MonitID + " -o UserKnownHostsFile=/dev/null   rma@monit.docker sudo sh /home/rmsite.sh"               
        #   @CidDir=SysConfig.CidDir #"/opt/mpas/run"
      
         end

 
  def save_state(docker_api)
      docker_api.save_container self
      
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
	
	def create_service(docker_api) 
	  puts ("create")
    create_container(docker_api)
    self.save_state(docker_api)
	 #re add consumsers   
	end
		
  def recreate
    destroy_container(docker_api)
    create_service(docker_api)
    reregister_consumers(docker_api)
      
    end
    
    def reregister_consumers
    end
    
  def destroy 
    
   end
   
   def deleteimage
     #noop never do  this as need buildimage again or only for expert 
   end
  def self.from_yaml( yaml,docker_api )
          managedService = YAML::load( yaml )
          managedService.set_docker_api(docker_api)
          return managedService
    end
end
	