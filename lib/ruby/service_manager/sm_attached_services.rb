module SMAttachedServices
  
  #@return [Array] of service hash for ObjectName matching the name  identifier
    #@objectName [String]
    #@identifier [String]
    def list_attached_services_for(objectName,identifier)
      clear_error
      SystemDebug.debug(SystemDebug.services,'services_on_objects_',objectName)
      SystemDebug.debug(SystemDebug.services,'services_on_objects_',identifier)
      params = {}
      case objectName
      when 'ManagedEngine'
        # FIXME: get from Object
        params[:parent_engine] = identifier
        params[:container_type] = 'container'
        
          
        SystemDebug.debug(SystemDebug.services,  :get_engine_service_hashes,'ManagedEngine')
        #      hashes = system_registry_client.find_engine_services_hashes(params)
        #      SystemUtils.debug_output('hashes',hashes)
  
        return test_registry_result(system_registry_client.find_engine_services_hashes(params))
        #    attached_managed_engine_services(identifier)
      when 'Volume'
        SystemDebug.debug(SystemDebug.services,  :looking_for_volume,identifier)
        return attached_volume_services(identifier)
      when 'Database'
        SystemDebug.debug(SystemDebug.services,  :looking_for_database,identifier)
        return attached_database_services(identifier)
      end
      SystemDebug.debug(SystemDebug.services, :no_object_name_match, objectName)
      return nil
    rescue Exception=>e
      puts e.message
      log_exception(e)
      return params
    end

end