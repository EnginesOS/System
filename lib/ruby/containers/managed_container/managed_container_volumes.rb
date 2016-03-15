module ManagedContainerVolumes
  def add_volume(service_hash)
    permissions = PermissionRights.new(service_hash[:parent_engine] , '', '')
    vol = Volume.new(service_hash) #service_hash[:variables][:name], SystemConfig.LocalFSVolHome + '/' + service_hash[:parent_engine]  + '/' + service_hash[:variables][:name], service_hash[:variables][:engine_path], 'rw', permissions)
    if service_hash[:shared] == true
    @volumes[service_hash[:service_container_name] + '_' + service_hash[:variables][:service_name]] = vol
      else
    @volumes[service_hash[:variables][:name]] = vol
end
    save_state
  rescue StandardError => e
    log_exception(e,service_hash)
  end

def del_volume(service_hash)
  if service_hash[:shared] == true
      @volumes.delete(service_hash[:service_container_name] + '_' + service_hash[:variables][:service_name])
        else
      @volumes.delete(service_hash[:variables][:name])
    save_state
  end
  rescue StandardError => e
      log_exception(e,service_hash)
end

end