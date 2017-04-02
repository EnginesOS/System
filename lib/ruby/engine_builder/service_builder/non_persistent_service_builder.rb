module NonPersistantServiceBuilder
  def create_non_persistent_services(services)
    services.each do |service_hash|
      service_def = SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
      raise EngineBuilderException.new(error_hash(error_hash('Failed to load service definition for ', service_hash))) if service_def.nil?
      next if service_def[:persistent]
      service_hash = set_top_level_service_params(service_hash, @engine_name)
      @core_api.create_and_register_service(service_hash)
      @attached_services.push(service_hash)
    end
     true

  end

end