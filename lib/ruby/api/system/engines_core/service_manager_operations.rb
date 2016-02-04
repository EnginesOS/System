module ServiceManagerOperations

  require_relative 'service_manager_access.rb'
  def register_non_persistent_services(engine)
    service_manager.register_non_persistent_services(engine)
  end

  def deregister_non_persistent_services(engine)
    service_manager.deregister_non_persistent_services(engine)
  end

  def load_and_attach_services(dirname, container)
    service_manager.load_and_attach_services(dirname, container)
  end

  def get_service_configuration(service_param)
    service_manager.get_service_configuration(service_param)
  end

  def is_service_running?(service_name)
    service_manager.is_service_running?(service_name)
  end

  def rollback_shared_service(service_hash)
    service_manager.rollback_orphaned_service(service_hash)
  end

  def get_service_entry(service_hash)
    service_manager.get_service_entry(service_hash)
  end

  def taken_hostnames
    query= {}
    query[:type_path]='nginx'
    query[:publisher_namespace] = "EnginesSystem"

    sites = []
    hashes = service_manager.all_engines_registered_to('nginx')
    return sites unless hashes.is_a?(Array)    
    hashes.each do |service_hash|
      sites.push(service_hash[:variables][:fqdn])
    end
    return sites
  rescue StandardError => e
    log_exception(e)
  end

end