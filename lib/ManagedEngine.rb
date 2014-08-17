class ManagedEngine < ManagedContainer
  @ctype="container"

  
  def initialize(name,type,memory,hostname,domain_name,image,volumes,port,eports,repo,dbs,environments,framework,runtime)
            
                 @ctype =type
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
                 @repo=repo
                 @last_result=""
                 @setState="nocontainer"
                 @databases=dbs
                 @monitored=false
                 @registerSite=true
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
 
  def self.from_yaml( yaml )
          managedContainer = YAML::load( yaml )
          managedContainer
    end
end
  