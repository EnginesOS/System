module ServiceChecks
  def required_services_are_running?
    @attached_services.each do |service_hash|
      service_name = SoftwareServiceDefinition.get_software_service_container_name(service_hash)
      SystemDebug.debug(SystemDebug.builder,:checking_service, service_name.to_s)
      raise EngineBuilderException.new(error_hash('Required Service not running ' + service_name.to_s)) unless @core_api.is_service_running?(service_name)
    end
    true
  end
end