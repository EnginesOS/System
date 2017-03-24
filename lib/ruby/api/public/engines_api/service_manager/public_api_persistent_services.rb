module PublicApiPersistentServices
  def registered_with_service(service_hash)
    return @core_api.registered_with_service(service_hash)
  end

  def retrieve_service_hash(query_hash)
    @core_api.retrieve_service_hash(query_hash)
  end

end