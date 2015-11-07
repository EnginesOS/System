module ServiceChecks

def required_services_are_running?
  
  @attached_services.each do |service_hash|  
   service_name = SoftwareServiceDefinition.get_software_service_container_name(service_hash)
    return service_not_running(service_name) unless @service_manager.is_service_running?(service_name)
  end
end

def service_not_running(service_name)
  @last_error = service_name.to_s + ' Not Running'
end
end