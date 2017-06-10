module ServiceChecks
  def required_services_are_running?
    @attached_services.each do |service_hash|
      service_def = SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])  
      SystemDebug.debug(SystemDebug.builder, :checking_service, service_def[:service_container].to_s)        
      next if service_def.key?(:soft_service) && service_def[:soft_service] == true
      raise EngineBuilderException.new(error_hash('Required Service not running ' + service_def[:service_container].to_s)) unless @core_api.is_service_running?(service_def[:service_container])
    end
    true
  end
end