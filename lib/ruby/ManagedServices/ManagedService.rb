require "/opt/engines/lib/ruby/ManagedContainer.rb"
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
    if is_running ==true    
      result = add_consumer_to_service(site_hash)
      if result == true
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
    @consumers.store(site_hash[:name], site_hash)

    # end
    save_state
    return result
  end

  def remove_consumer engine
    site_hash = get_site_hash(engine)
      if is_running ==true   
        result = rm_consumer_from_service(site_hash)
         if result == true
          sm =  service_manager
            if sm != false
              result sm.remove_service(site_hash)
            else
              return false
            end
         end
      end

    if @consumers !=  nil 
      @consumers.delete(site_hash[:name]) { |el| "#{el} not found" }

    end
    save_state
    return result
  end

  def service_manager
    return @core_api.loadManagedService("ServiceManager")
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
