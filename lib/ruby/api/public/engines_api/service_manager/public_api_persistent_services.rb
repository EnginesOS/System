module PublicApiPersistentServices
  def get_registered_against_service(service_hash)
    return @core_api.get_registered_against_service(service_hash)
  end

  def retrieve_service_hash(query_hash)
    @core_api.retrieve_service_hash(query_hash)
  end

end