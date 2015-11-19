module ServiceManagerOperations
  

 
  
  def register_non_persistant_services(engine)
    service_manager.register_non_persistant_services(engine)
  end

  def deregister_non_persistant_services(engine)
    service_manager.deregister_non_persistant_services(engine)
  end

  def load_and_attach_services(dirname, container)
    service_manager.load_and_attach_services(dirname, container)
  end

  def get_service_configuration(service_param)
    service_manager.get_service_configuration(service_param)
  end


  
  def taken_hostnames
      query= {}
      query[:type_path]='nginx'
      query[:publisher_namespace] = "EnginesSystem"
  
      sites = []
      hashes = service_manager.all_engines_registered_to('nginx')
      return sites if hashes == false
      hashes.each do |service_hash|
        sites.push(service_hash[:variables][:fqdn])
      end
      return sites
    rescue StandardError => e
      log_exception(e)
    end

end