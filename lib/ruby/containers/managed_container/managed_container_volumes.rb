module ManagedContainerVolumes
  def add_volume(service_hash)
    SystemDebug.debug(SystemDebug.services, 'add volume', service_hash)
    permissions = PermissionRights.new(service_hash[:parent_engine] , '', '')
    vol = Volume.volume_hash(service_hash) 
    if service_hash[:shared] == true
      @volumes[service_hash[:service_owner] + '_' + service_hash[:variables][:service_name]] = vol
    else
      @volumes[service_hash[:variables][:service_name]] = vol
    end
    save_state
  end

  def del_volume(service_hash)
    if service_hash[:shared] == true
      @volumes.delete(service_hash[:service_container_name] + '_' + service_hash[:variables][:service_name])
    else
      @volumes.delete(service_hash[:variables][:service_name])
      save_state
    end
  end

end