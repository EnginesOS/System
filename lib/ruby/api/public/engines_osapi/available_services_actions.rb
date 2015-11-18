module AvailableServicesActions

  # @returns list of availible
  def list_avail_services_for(object)
    @core_api.list_avail_services_for(object)
  end

  def load_avail_services_for_type(type)
    @core_api.load_avail_services_for_type(type)
  end


  # @ retruns [SoftwareServiceDefinition]
  # for type_path [String] and service_provider[String]
  def get_service_definition(type_path, service_provider)
    SoftwareServiceDefinition.find(type_path, service_provider)
  end


 
  # @ retruns [SoftwareServiceDefinition]
  # for params :type_path :publisher_namespace
  def software_service_definition(params)
    retval = @core_api.software_service_definition(params)
    return retval if retval.nil? == false
    failed(params[:type_path] + ':' + params[:publisher_namespace], @core_api.last_error, 'get software_service_definition')
  end
  
  def load_avail_services_for_type(typename)
    @core_api.load_avail_services_for_type(typename)
  end

  def list_attached_services_for(object_name, identifier)
    SystemUtils.debug_output('list_attached_services_for', object_name + ' ' + identifier)
    @core_api.list_attached_services_for(object_name, identifier)
  end

end