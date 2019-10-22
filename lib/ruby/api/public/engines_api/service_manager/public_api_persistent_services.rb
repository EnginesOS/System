module PublicApiPersistentServices
  def registered_with_service(service_hash)
    core.registered_with_service(service_hash)
  end

  def retrieve_service_hash(query_hash)
    core.retrieve_service_hash(query_hash)
  end

end
