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

  def consumers
    if @consumers == nil
      @consumers = Hash.new
    end
    return @consumers
  end

  def get_site_hash(site_hash)
    
    if site_hash.is_a?(Hash) == false     
      site_hash = create_site_hash(site_hash)
    end

    if site_hash.has_key?(:service_handle) == false
         site_hash[:service_handle] = site_hash[:variables][:name]
     end
     if site_hash[:variables].has_key?(:parent_name) == false
       site_hash[:variables][:parent_name] = site_hash[:parent_name]
       
     end          
      return site_hash
  end

  def fetch_consumer name
    return @consumers.fetch(name)
  end

  def add_consumer(engine)
    site_hash = get_site_hash(engine)
    if is_running ==true   || @persistant == true 
      result = add_consumer_to_service(site_hash)
      if result == true
        p :adding_consumer_to_Sm
        p site_hash 
        sm =  service_manager
          if sm != false                      
            result = sm.add_service(site_hash)
          else 
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

    #      if @consumers.has_key?(site_hash[:name]) == true     # only add if doesnt exists but allow register above
    @consumers.store(site_hash[:variables][:name], site_hash)

    # end
    save_state
    return result
  end

  def remove_consumer service_hash
    
    service_hash = get_site_hash(service_hash)
    if service_hash == nil
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
              return false
            end
         end
      end

    if @consumers !=  nil 
      @consumers.delete(service_hash[:variables][:name]) { |el| "#{el} not found" }
    end
    save_state
    return result
  end

  def service_manager
    return @core_api.loadServiceManager()
  end
  
  def create_service()

    if create_container() ==true
      reregister_consumers()
      save_state()
      return true
    else
      return false
    end
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
    if is_running == false
      return
    end
    
    loop_cnt=0
    
    while is_startup_complete() == false && loop_cnt <10
      loop_cnt = loop_cnt + 1
      sleep 1    
      #really need to sched it not block for some random time
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
   
end
