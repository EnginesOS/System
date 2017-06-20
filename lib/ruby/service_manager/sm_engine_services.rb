module SmEngineServices
  require_relative 'private/service_container_actions.rb'
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
      STDERR.puts('NO services ' +  engine.container_name.to_s + ';' + e.to_s)
      false # No services
    end

    services.each do |service_hash|
      begin
        system_registry_client.remove_from_services_registry(service_hash)
        remove_from_managed_service(service_hash)
      rescue StandardError => e
        STDERR.puts('removing_services excepti' + service_hash.to_s + ':' + e.to_s)
        next
      end
    end
    true
  end

  def list_persistent_services(engine)
    get_engine_persistent_services({
      parent_engine: engine.container_name,
      container_type: engine.ctype
    })
  end

  def list_non_persistent_services(engine)
    get_engine_nonpersistent_services({
      parent_engine: engine.container_name,
      container_type: engine.ctype
    })
  end

  #service manager get non persistent services for engine_name
  #for each servie_hash load_service_container and add hash
  #add to service registry even if container is down
  def register_non_persistent_services(engine)
    services = get_engine_nonpersistent_services({
      parent_engine: engine.container_name,
      container_type: engine.ctype
    })
    SystemDebug.debug(SystemDebug.services,:register_non_persistent, services)
   # return services  unless services.is_a?(Array)
    services.each do |service_hash|
      begin
        register_non_persistent_service(service_hash)
        SystemDebug.debug(SystemDebug.services,:register_non_persistent,service_hash)
      rescue
        next
      end
    end
    true
  end

  def remove_engine_non_persistent_services(params)
    #   STDERR.puts('remove_engine_services ' + params.to_s)
    begin
      services = get_engine_nonpersistent_services(params) # find_engine_services_hashes(params)
    rescue
      return nil
    end
    #   return services unless services.is_a?(Array)
    #   STDERR.puts('remove_engine_services ' + services.to_s)
    services.each do |s|
      #    STDERR.puts('remove_engine_service ' + s.to_s)
      begin
        system_registry_client.remove_from_managed_engine(s)
      rescue
        next
      end
    end
  end

  def retrieve_cron_jobs(container)
    retrieve_engine_service_hashes({
      parent_engine: container.container_name,
      publisher_namespace: 'EnginesSystem',
      type_path: 'cron',
      container_type: container.ctype,
      container_name: container.container_name
    })
  end

  def retrieve_cron_entry(cronjob, container)
    retrieve_engine_service_hash({
      parent_engine: container.container_name,
      publisher_namespace: 'EnginesSystem',
      type_path: 'cron',
      container_type: container.ctype,
      container_name: container.container_name,
      service_handle:  cronjob})[:variables][:cron_job]
  end

  # @ remove an engine matching :engine_name from the service registry, all non persistent serices are removed
  # @ if :remove_all_data is true all data is deleted and all persistent services removed
  # @ if :remove_all_data is not specified then the Persistant services registered with the engine are moved to the orphan services tree
  # @return true on success and false on fail
  def remove_managed_persistent_services(params)
    begin
      services = get_engine_persistent_services(params)  #system_registry_client.
    rescue # StandardError => e
      #handle_exception(e)
      return true
    end
    #  return true unless services.is_a?(Array)
    services.each do | service |
      SystemDebug.debug(SystemDebug.services, :remove_service, service)
      if params[:remove_all_data] == 'all' || service[:shared] #&& ! (service.key?(:shared) && service[:shared])
        service[:remove_all_data] = params[:remove_all_data]
        service[:force] = true if params.key?(:force)
        begin
          delete_and_remove_service(service)
        rescue StandardError => e
          STDERR.puts(' remove_managed_persistent_services ' + e.to_s)
          next
        end
      else
        orphanate_service(service)
        system_registry_client.remove_from_managed_engine(service)
      end
    end
    true
  end
end