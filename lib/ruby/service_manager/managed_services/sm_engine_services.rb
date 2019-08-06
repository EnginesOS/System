module SmEngineServices
  #def find_engine_services(params)
  #  system_registry_client.find_engine_services(params)
  #end
  def find_engine_services_hashes(params)
    system_registry_client.find_engine_services_hashes(params)
  end
  #

  def retrieve_engine_service_hash(params)
    system_registry_client.retrieve_engine_service_hash(params)
  end

  # @return [Array] of all service_hashs marked persistence true for :engine_name
  def get_engine_persistent_services(params)
    system_registry_client.get_engine_persistent_services(params)
  end

  # @return [Array] of all service_hashs marked persistence false for :engine_name
  # required keys
  # :engine_name

  def get_engine_nonpersistent_services(params)
    system_registry_client.get_engine_nonpersistent_services(params)
  end

  #service manager get non persistent services for engine_name
  #for each servie_hash load_service_container and remove hash
  #remove from service registry even if container is down
  def deregister_non_persistent_services(engine)
    begin
      services = get_engine_nonpersistent_services({
        parent_engine: engine.container_name,
        container_type: engine.ctype
      })
    rescue StandardError => e
      # STDERR.puts('NO services ' +  engine.container_name.to_s + ';' + e.to_s)
      # return false # No services
      services = nil
    end
    if services.is_a?(Array)
      services.each do |service_hash|
        begin
          system_registry_client.remove_from_services_registry(service_hash)
          remove_from_managed_service(service_hash)
        rescue StandardError => e
          STDERR.puts('removing_services exception' + service_hash.to_s + ':' + e.to_s)
          next
        end
      end
      true
    end
  end

  #service manager get non persistent services for engine_name
  #for each servie_hash load_service_container and add hash
  #add to service registry even if container is down
  def register_non_persistent_services(engine)
    services = get_engine_nonpersistent_services({
      parent_engine: engine.container_name,
      container_type: engine.ctype
    })
    # SystemDebug.debug(SystemDebug.services,:register_non_persistent, services)
    if services.is_a?(Array)
      services.each do |service_hash|
        begin
          register_non_persistent_service(service_hash)
          # SystemDebug.debug(SystemDebug.services,:register_non_persistent,service_hash)
        rescue
          next
        end
      end
      true
    end
  end

  def remove_engine_non_persistent_services(params)
    #   STDERR.puts('remove_engine_services ' + params.to_s)
    begin
      services = get_engine_nonpersistent_services(params) # find_engine_services_hashes(params)
    rescue
      return
    end
    #   return services unless services.is_a?(Array)
    #   STDERR.puts('remove_engine_services ' + services.to_s)
    if services.is_a?(Array)
      services.each do |s|
        #    STDERR.puts('remove_engine_service ' + s.to_s)
        begin
          system_registry_client.remove_from_managed_engine(s)
        rescue
          next
        end
      end
    end
  end

  def import_engine_registry(registry)
    services = get_all_leafs_service_hashes(registry)
    services.each do |service|
      STDERR.puts(' CAR ' + service.to_s)
      create_and_register_service(service)
    end
  end

  # @ remove an engine matching :engine_name from the service registry, all non persistent serices are removed
  # @ if :remove_all_data is true all data is deleted and all persistent services removed
  # @ if :remove_all_data is not specified then the Persistant services registered with the engine are moved to the orphan services tree
  # @return true on success and false on fail
  def remove_managed_persistent_services(params)
    begin
      services = get_engine_persistent_services(params)  #system_registry_client.
    rescue
      services = nil
    end
    #  STDERR.puts('RM SERVICES: ' + params.to_s  + ' Services' + services.to_s)
    if services.is_a?(Array)
      services.each do | service |
        #STDERR.puts('RM SERVICE: ' + service.to_s)
        service[:lost] = params[:lost] if params.key?(:lost)
        service[:remove_all_data] = params[:remove_all_data] if params.key?(:remove_all_data)
        #   STDERR.puts('RM SERVICE: ' + service.to_s)
        delete_and_remove_service(service)
      end
    end
  end
end

private

def get_all_leafs_service_hashes(branch)
  return if branch.nil?
  if branch.children.count == 0
    branch.content if branch.content.is_a?(Hash)
  else
    ret_val = []
    # SystemUtils.debug_output('top node',branch.name)
    branch.children.each do |sub_branch|
      #    SystemUtils.debug_output('on node',sub_branch.name)
      if sub_branch.children.count == 0
        ret_val.push(sub_branch.content) if sub_branch.content.is_a?(Hash)
      else
        ret_val.concat(get_all_leafs_service_hashes(sub_branch))
      end
    end
    ret_val
  end
  
end
