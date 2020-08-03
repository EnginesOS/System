class PublicApi 
  def retrieve_engine_service_hash(query_hash)
    core.retrieve_engine_service_hash(query_hash)
  end

  def find_service_service_hash(query_hash)
    query_hash[:container_type] = 'service'
    core.retrieve_engine_service_hash(query_hash)
  end

  def retrieve_engine_service_hashes(query_hash)
    core.find_engine_services_hashes(query_hash)
  end

  def find_service_service_hashes(query_hash)
    query_hash[:container_type] = 'service'
    core.retrieve_engine_service_hashes(query_hash)
  end

end
