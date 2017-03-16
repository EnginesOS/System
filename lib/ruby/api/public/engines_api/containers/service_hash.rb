module PublicApiContainersServiceHash
  def find_engine_service_hash(query_hash)
    @core_api.find_engine_service_hash(query_hash)
  rescue StandardError => e
    handle_exception(e)
  end

  def find_service_service_hash(query_hash)
    query_hash[:container_type] = 'service'
    @core_api.find_engine_services_hashes(query_hash)
  rescue StandardError => e
    handle_exception(e)
  end

  def find_engine_service_hashes(query_hash)
    @core_api.find_engine_services_hashes(query_hash)
  rescue StandardError => e
    handle_exception(e)
  end

  def find_service_service_hashes(query_hash)
    query_hash[:container_type] = 'service'
    @core_api.find_engine_service_hashes(query_hash)
  rescue StandardError => e
    handle_exception(e)
  end

end