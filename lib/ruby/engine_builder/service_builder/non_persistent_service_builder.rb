module NonPersistantServiceBuilder
  def create_non_persistent_services(services)
    services.each do |service_hash|
      service_def = SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
      return log_error_mesg('Failed to load service definition for ', service_hash) if service_def.nil?
      next if service_def[:persistent]
      service_hash = set_top_level_service_params(service_hash, @engine_name)
      return log_error_mesg('Failed to Attach ', service_hash) unless @core_api.create_and_register_service(service_hash)
      @attached_services.push(service_hash)
    end
    return true
    rescue StandardError => e
      log_exception(e)
  end

end