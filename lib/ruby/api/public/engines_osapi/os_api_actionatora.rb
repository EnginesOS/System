module OsApiActionators
  def list_actionators(service)
    if service.is_a?(Hash)
      SoftwareServiceDefinition.software_service_definition(service)
    else
      service_def = SoftwareServiceDefinition.find(service.type_path,service.publisher_namespace)
    end
    return [] unless service_def.is_a?(Hash)
    return [] unless service_def.key?(:actionators)
    return [] unless service_def[:actionators].is_a?(Array)
    return service_def[:actionators]
  end
  
  def perform_service_action(service_name,actionator_name,params)
    
  end
  
end