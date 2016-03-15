module ManagedContainerVolumes
  def add_volume(service_hash)
    permissions = PermissionRights.new(service_hash[:parent_engine] , '', '')
    vol = Volume.new(service_hash) #service_hash[:variables][:name], SystemConfig.LocalFSVolHome + '/' + service_hash[:parent_engine]  + '/' + service_hash[:variables][:name], service_hash[:variables][:engine_path], 'rw', permissions)
    if service_hash[:shared] == true
    @volumes[service_hash[:parent_engine] + '_' + service_hash[:service_name]] = vol
      else
    @volumes[service_hash[:variables][:name]] = vol
end
    save_state
  rescue StandardError => e
    log_exception(e,service_hash)
  end


end