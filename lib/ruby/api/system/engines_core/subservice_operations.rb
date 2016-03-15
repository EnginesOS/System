module SubserviceOperations

  require_relative 'service_manager_access.rb'
  def attach_subservice(service_query)
    
    return false unless check_sub_service_hash(service_query)
    ahash = service_manager.find_engine_service_hash(service_query)
       return log_error_mesg("cannot attach to shared service",params) if ahash[:shared] == true
    return attach_service(service_query) # if params.key?(:parent_service) && params[:parent_service].key?(:publisher_namespace) && params[:parent_service].key?(:type_path)    && params[:parent_service].key?(:service_handle)
    log_error_mesg('missing parrameters', service_query)
  end

  def dettach_subservice(service_query)
    return false unless check_sub_service_hash(service_query)
    dettach_service(service_query)
    log_error_mesg('missing parrameters', service_query)
  end

end