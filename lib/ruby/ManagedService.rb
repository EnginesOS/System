
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

 
 
    
  
	def consumers
	    if @consumers == nil
	      @consumers = Array.new
	    end
    return @consumers
	end
	

  def add_consumer(engine)
     site_string=engine.containerName + ":" + engine.fqdn + ":" + engine.port.to_s    
     ret_val = add_consumer_to_service(site_string,engine)
     if ret_val != true
       return false
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

   def add_consumer_to_service(site_string,engine)
     ip_str = engine.get_ip_str
      return  engine.docker_api.register_dns(engine.hostName,ip_str)
     
   end
   
   def rm_consumer_from_service (site_string,engine)
     ip_str = engine.get_ip_str
      return  engine.docker_api.deregister_dns(engine.hostName,ip_str)
   end

  def remove_consumer engine
      site_string=engine.containerName + ":" + engine.fqdn + ":" + engine.port.to_s   
      result = rm_consumer_from_service(site_string,engine)
     
      if(@consumers !=  nil || @consumes.length>0)
             @consumers.delete(site_string)
          end    
      save_state
      return result
    end
	def create_service() 
	
    if create_container() ==true
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
	