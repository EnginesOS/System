require "/opt/engines/lib/ruby/containers/ManagedContainer.rb"
require 'objspace'

class ManagedService < ManagedContainer
  @ctype="service"
  @consumers=Hash.new
  @conf_register_site=false
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
    @persistant=false  #Persistant means niether service or engine need to be up/running or even exist for this service to exist
  end

  #@return Hash of consumers 
  #creates fresh hash in instance @consumers is nil
  def consumers
    if @consumers == nil
      @consumers = Hash.new
    end
    return @consumers
  end

  
  def get_service_hash(service_hash)
    
    if service_hash.is_a?(Hash) == false
      log_error_mesg("Get service hash on ",service_hash)
      service_hash = create_service_hash(service_hash)
    end
    return service_hash
 end
     
#    #Kludge suring service_hash cut over
#    if service_hash.has_key?(:service_handle) == false
#      service_hash[:service_handle] = service_hash[:variables][:name]
#    end
#    if service_hash[:variables].has_key?(:parent_engine) == false
#      service_hash[:variables][:parent_engine] = service_hash[:parent_engine]
#    elsif service_hash.has_key?(:parent_engine) == false
#      service_hash[:parent_engine] = service_hash[:variables][:parent_engine]
#
#    end
   

#  def fetch_consumer name
#    return @consumers.fetch(name)
#  end

  def add_consumer(object)
  
    service_hash = get_service_hash(object)
    if service_hash == nil
      log_error_mesg("add consumer passed nil service_hash ","")
      p "nil site hash"
      return false
    end
    service_hash[:persistant] =@persistant

    if is_running ==true   || @persistant == true
        if service_hash[:fresh] == false
          result = true
        else
      result = add_consumer_to_service(service_hash)
        end
        
      if result == true
        service_hash[:fresh] = false
        p :adding_consumer_to_Sm
        p service_hash
        sm =  service_manager
        if sm != false
          result = sm.add_service(service_hash)
        else
          log_error_mesg("add consumer no ServiceManager ","")
          return false
        end
      end
    end
    #note we add to service regardless of whether the consumer is already registered
    #for a reason

    if result != true
      return result
    end
#
#    if @consumers == nil
#      @consumers = Hash.new
#    end
#
#    #      if @consumers.has_key?(service_hash[:name]) == true     # only add if doesnt exists but allow register above
#    @consumers.store(service_hash[:service_handle], service_hash)

    # end
    save_state
    return result
  end
  def service_hash_variables_as_str(service_hash)
    argument = String.new
      
    service_variables =  service_hash[:variables]
      if service_variables == nil
        return argument
      end
    service_variables.each_pair do |key,value|
      argument+= key.to_s + "=" + value + ":"      
    end
    
    return argument
  end
  
  def   add_consumer_to_service(service_hash)   
  cmd = "docker exec " +  containerName + " /home/create_service.sh " + service_hash_variables_as_str(service_hash)
    SystemUtils.run_system(cmd)
  end
  
  def   rm_consumer_from_service(service_hash) 
   cmd = "docker exec " +  containerName + " /home/rm_service.sh " + service_hash_variables_as_str(service_hash)
     SystemUtils.run_system(cmd)
  end 
  
  def remove_consumer service_hash
   
    service_hash = get_service_hash(service_hash)
    if service_hash == nil
      log_error_mesg("remove consumer nil service hash ","")
      return false
    end
    if is_running != true
      log_error_mesg("Cannot remove consumer if Service is not running ",service_hash)
      return false
    end
    
    if @persistant == true    
     if  service_hash.has_key?(:remove_all_application_data)  && service_hash[:remove_all_application_data] == true 
      p :removing_consumer
      result = rm_consumer_from_service(service_hash)
      if result == true
        sm =  service_manager
        if sm != false
          p :remove_consumer
          p service_hash
          result =  sm.remove_service(service_hash)
        else
          log_error_mesg("rm consumer no ServiceManager ","")
          return false
        end
      end      
     end
      
    end
    
    if @consumers !=  nil
      @consumers.delete(service_hash[:service_handle]) { |el|  log_error_mesg("Failed to find " + el.to_s + "to del ",service_hash)  }
    end
    save_state
    return result
  end

  def service_manager
    return @core_api.loadServiceManager()
  end

  def create_service()
   
    if create_container() ==true
      register_dns()
      reregister_consumers()
      save_state()
      return true
    else
      log_error_mesg("Failed to create service",self)
      return false
    end
  end

  
  #Register the dns
  #bootsrap service dns into ManagedService registry
  #would be better if it check a pre exisiting record will throw error on recreate
  # 
   def register_dns
     service_hash = SystemUtils.create_dns_service_hash(self)
     if service_hash == nil
       return false
     end
     return  @core_api.attach_service(service_hash)
   end
  
  def recreate
    
    if  destroy_container() ==true
      if   create_service()==true       
        return true
      else
        log_error_mesg("Failed to create service in recreate",self)
              
        return false
      end
    else
      log_error_mesg("Failed to destroy service in recreate",self)
      return false
    end
  end

  def reregister_consumers
    
    if @consumers == nil
      return
    end
    if is_running == false
      log_error_mesg("Cant register consumers as not running ",self)
      return
    end

    loop_cnt=0

    while is_startup_complete() == false && loop_cnt <10
      loop_cnt = loop_cnt + 1
      sleep 1
      #really need to sched it not block for some random time
    end

    @consumers.each_value do |service_hash|
      add_consumer_to_service(service_hash)
    end

  end

  def destroy
    log_error_mesg("Cannot call destroy on a service",self)
    return false
  end

  def deleteimage
    log_error_mesg("Cannot call deleteimage on a service",self)
    return false
    #noop never do  this as need buildimage again or only for expert
  end

  def self.from_yaml( yaml,core_api )
   
    begin
      p yaml.path
      managedService = YAML::load( yaml )
      managedService.core_api=(core_api)
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

  def set_container_pid

    pid ="-1"

  end
  
  #Sets @last_error to msg + object.to_s (truncated to 256 chars)
   #Calls SystemUtils.log_error_msg(msg,object) to log the error
   #@return none
  def self.log_error_mesg(msg,object)
     obj_str = object.to_s.slice(0,256)
     
    
    SystemUtils.log_error_msg(msg,object)
  
   end
end
