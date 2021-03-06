class ServiceManager  
  # @return [Array] of service hash for ObjectName matching the name  identifier
  # @objectName [String]
  # @identifier [String]
  def services_attached_to(objectName, identifier)
   # SystemDebug.debug(SystemDebug.services, 'services_on_objects_', objectName)
   # SystemDebug.debug(SystemDebug.services, 'services_on_objects_', identifier)
    params = {}
    case objectName
    when 'ManagedEngine'
      # FIXME: get from Object
      params[:parent_engine] = identifier
      params[:container_type] = 'app'
     # SystemDebug.debug(SystemDebug.services, :get_engine_service_hashes, 'ManagedEngine')
      return system_registry_client.find_engine_services_hashes(params)
    when 'ManagedService'
      params[:parent_engine] = identifier
      params[:container_type] = 'service'
      return system_registry_client.find_engine_services_hashes(params)
    when 'Volume'
     # SystemDebug.debug(SystemDebug.services, :looking_for_volume, identifier)
      return attached_volume_services(identifier)
    when 'Database'
     # SystemDebug.debug(SystemDebug.services, :looking_for_database, identifier)
      return attached_database_services(identifier)
    end
   # SystemDebug.debug(SystemDebug.services, :no_object_name_match, objectName)
    nil
  end
end