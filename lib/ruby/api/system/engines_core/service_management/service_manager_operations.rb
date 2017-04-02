module ServiceManagerOperations

  require_relative 'service_manager_access.rb'
  def register_non_persistent_services(engine)
    service_manager.register_non_persistent_services(engine)
  end

  def deregister_non_persistent_services(engine)
    service_manager.deregister_non_persistent_services(engine)
  end

  def retrieve_engine_service_hash(params)
    params[:container_type] = 'container' unless params.key?(:container_type)
    service_manager.retrieve_engine_service_hash(params)
  end

  def find_engine_services_hashes(hash)
    hash[:container_type] = 'container' unless params.key?(:container_type)
    service_manager.find_engine_services_hashes(hash)   
  end
  
  def find_service_services_hashes(hash)
    hash[:container_type] = 'service' 
    service_manager.find_engine_services_hashes(hash)   
  end

  def find_service_service_hash(params)
    params[:container_type] = 'service' #was container CNP error?
    service_manager.retrieve_engine_service_hash(params)
  end

  def list_persistent_services(engine)
    service_manager.list_persistent_services(engine)
  end

  def list_non_persistent_services(engine)
    service_manager.list_non_persistent_services(engine)
  end

  def load_and_attach_static_services(dirname, container)
    service_manager.load_and_attach_static_services(dirname, container)
  end
#
#  def retrieve_service_configuration(service_param)
#    service_manager.retrieve_service_configuration(service_param)
#  end

  def is_service_running?(service_name)
    service_manager.is_service_running?(service_name)
  end

  def rollback_shared_service(service_hash)
    service_manager.rollback_shared_service(service_hash)
  end

  def get_service_entry(service_hash)
    service_manager.get_service_entry(service_hash)
  end

  def retreive_cron_entry(cronjob, container)
    service_manager.retrieve_cron_entry(cronjob, container)
  end

  def taken_hostnames
    hashes = service_manager.all_engines_registered_to('nginx')
    return sites unless hashes.is_a?(Array)
    sites = []
    hashes.each do |service_hash|
      SystemDebug.debug(SystemDebug.services,  'service_hash is a' + service_hash.class.name)
      next unless service_hash.is_a?(Hash)
      next unless service_hash[:variables].is_a?(Hash)
      sites.push(service_hash[:variables][:fqdn])
    end
    sites
  end

end