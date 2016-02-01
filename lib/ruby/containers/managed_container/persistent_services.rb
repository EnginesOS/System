module PersistantServices
  
  def engine_persistent_services
    services = @container_api.engine_persistent_services(self)
    retval = ''
    if services.is_a?(Array)
      n=0
      services.each do |service|
        retval += ' ' unless n == 0
       # retval += service_to_str(service) #+ SystemUtils.service_hash_variables_as_str(service)
          retval += SystemUtils.service_hash_variables_as_str(service)
        n=1
      end
    elsif services.is_a?(Hash)
      retval = service_to_str(service_hash) #SystemUtils.service_hash_variables_as_str(services)
    end
    p :engine_persistent_services
    p retval
    return  retval
  end
  
  # patha-pathb-servicetype.service_handle.param1.param2.param3
  
end

def service_to_str(service_hash)
  retval = service_hash[:publisher_namespace].to_s + '/' + service_hash[:type_path].to_s 
  service_hash[:variables].each do |variable|
    retval += ',' + variable[1].to_s
  end
  p :service_to_str
  p retval
  retval
    
end