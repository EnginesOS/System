module PersistantServices
  
  def engine_persistant_services
    services = @container_api.engine_persistant_services(self)
    retval = ''
    if services.is_a?(Array)
      services.each do |service|
        retval += ' ' + SystemUtils.service_hash_variables_as_str(service)
      end
    elsif services.is_a?(Hash)
      retval = SystemUtils.service_hash_variables_as_str(services)
    end
    return retval
  end
  
  
end