require "/opt/engines/lib/ruby/containers/ManagedContainer.rb"
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
    clear_error(true)
    if service_hash.is_a?(Hash) == false
      SystemUtils.log_error_msg("Get service hash on ",service_hash)
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
   

  def fetch_consumer name
    return @consumers.fetch(name)
  end

  def add_consumer(object)
  clear_error(true)
    service_hash = get_service_hash(object)
    if service_hash == nil
      log_error_mesg("add consumer passed nil service_hash ","")
      p "nil site hash"
      return false
    end
    
    if is_running ==true   || @persistant == true
      result = add_consumer_to_service(service_hash)
      if result == true
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

    if @consumers == nil
      @consumers = Hash.new
    end

    #      if @consumers.has_key?(service_hash[:name]) == true     # only add if doesnt exists but allow register above
    @consumers.store(service_hash[:service_handle], service_hash)

    # end
    save_state
    return result
  end

  def remove_consumer service_hash
    clear_error(true)
    service_hash = get_service_hash(service_hash)
    if service_hash == nil
      log_error_mesg("remove consumer nil service hash ","")
      return false
    end

    if is_running ==true   && ( @persistant == false \
    || ( service_hash.has_key?(:delete_persistant)  && service_hash[:delete_persistant] == true ))
      p :removing_consumer
      result = rm_consumer_from_service(service_hash)
      if result == true
        sm =  service_manager
        if sm != false
          p :remove_consumer
          p service_hash
          result =  sm.remove_service(service_hash)
        else
          log_error_mesg("add consumer no ServiceManager ","")
          return false
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
    clear_error(true)
    if create_container() ==true
      reregister_consumers()
      save_state()
      return true
    else
      log_error_mesg("Failed to create service",self)
      return false
    end
  end

  def recreate
    clear_error(true)
    if  destroy_container() ==true
      if   create_service()==true
        reregister_consumers()
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
    clear_error(true)
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
    clear_error(true)
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
      log_error_mesg("Cannot load",self)
      puts e.message + " with " + yaml.path
      
    end
  end

  def set_container_pid

    pid ="-1"

  end

end
