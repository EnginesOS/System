module PersistantServices
  
  def engine_persistant_services
    services = @container_api.engine_persistant_services(self)
    retval = ''
    if services.is_a?(Array)
      n=0
      services.each do |service|
        retval += ' ' + service_to_str(service_hash) #+ SystemUtils.service_hash_variables_as_str(service)
      end
    elsif services.is_a?(Hash)
      retval = service_to_str(service_hash) #SystemUtils.service_hash_variables_as_str(services)
    end
    return retval
  end
  
  # patha-pathb-servicetype.service_handle.param1.param2.param3
  
end

def service_to_str(service_hash)
  retval = service_hash[:publisher_namespace].to_s + ',' + service_hash[:type_path].to_s + ',' + service_hash[:type].to_s
  service_hash[:variables].each do |variable|
    retval += ',' + variable[0].to_s + '%'  + variable[1].to_s
  end
  p :service_to_str
  p retval
  retval+= ' '
  retval
    
end