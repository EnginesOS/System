module PersistantServices
  def engine_persistent_services
    services = @container_api.engine_persistent_services(self)
    service_details = []
    services.each do |service|
      service_detail = service.dup
      service_detail.delete(:variables)
      service_details.push(service_detail)
    end
    retval = service_details.to_json
    SystemDebug.debug(SystemDebug.services, :engine_persistent_services, retval)
    retval.gsub!(/\"\[/,'[')
    SystemDebug.debug(SystemDebug.services, :engine_persistent_services, retval)
    retval.gsub!(/\]\"/,']')
    SystemDebug.debug(SystemDebug.services, :engine_persistent_services, retval)
    retval
  end

  # patha-pathb-servicetype.service_handle.param1.param2.param3

end

def service_to_str(service_hash)
  retval = service_hash[:publisher_namespace].to_s + '/' + service_hash[:type_path].to_s
  service_hash[:variables].each do |variable|
    retval += ',' + variable[1].to_s
  end
  SystemDebug.debug(SystemDebug.services,  :service_to_str, retval)
  retval

end