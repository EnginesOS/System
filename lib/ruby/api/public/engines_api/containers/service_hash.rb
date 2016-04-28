module PublicApiContainersServiceHash
  
  def find_engine_service_hash(query_hash)
    @service_manager.find_engine_service_hash(query_hash)
  end
  
  def find_service_service_hash(query_hash)
      query_hash[:container_type] = 'service'
      @service_manager.find_engine_services_hashes(query_hash)
    end
    
  def find_engine_service_hashes(query_hash)
    @service_manager.find_engine_services_hashes(query_hash)
  end
  
  def find_service_service_hashes(query_hash)
      query_hash[:container_type] = 'service'
      @service_manager.find_engine_service_hashes(query_hash)
    end
    
end