module ServiceChecks
  def required_services_are_running?

    @attached_services.each do |service_hash|
      service_name = SoftwareServiceDefinition.get_software_service_container_name(service_hash)
      SystemDebug.debug(SystemDebug.builder,:checking_service, service_name.to_s)
      return service_not_running(service_name) unless @core_api.is_service_running?(service_name)
    end
    return true
    rescue StandardError => e
      log_exception(e)
  end

  def service_not_running(service_name)
    @last_error = service_name.to_s + ' Not Running please start/enable before installing this software'
    return false
    rescue StandardError => e
      log_exception(e)
  end
end