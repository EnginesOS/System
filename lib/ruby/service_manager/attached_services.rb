module AttachedServices
  
  #@return [Array] of service hash for ObjectName matching the name  identifier
    #@objectName [String]
    #@identifier [String]
    def list_attached_services_for(objectName,identifier)
      clear_error
      SystemUtils.debug_output('services_on_objects_',objectName)
      SystemUtils.debug_output('services_on_objects_',identifier)
      params = {}
      case objectName
      when 'ManagedEngine'
        # FIXME: get from Object
        params[:parent_engine] = identifier
        params[:container_type] = 'container'
        
          
        SystemUtils.debug_output(  :get_engine_service_hashes,'ManagedEngine')
        #      hashes = @system_registry.find_engine_services_hashes(params)
        #      SystemUtils.debug_output('hashes',hashes)
  
        return test_registry_result(@system_registry.find_engine_services_hashes(params))
        #    attached_managed_engine_services(identifier)
      when 'Volume'
        SystemUtils.debug_output(  :looking_for_volume,identifier)
        return attached_volume_services(identifier)
      when 'Database'
        SystemUtils.debug_output(  :looking_for_database,identifier)
        return attached_database_services(identifier)
      end
      p :no_object_name_match
      p objectName
      return nil
    rescue Exception=>e
      puts e.message
      log_exception(e)
      return params
    end

end