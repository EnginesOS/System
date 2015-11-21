module ManagedContainerVolumes
  def add_volume(service_hash)
     permissions = PermissionRights.new(service_hash[:parent_engine] , '', '')
     vol = Volume.new(service_hash) #service_hash[:variables][:name], SystemConfig.LocalFSVolHome + '/' + service_hash[:parent_engine]  + '/' + service_hash[:variables][:name], service_hash[:variables][:engine_path], 'rw', permissions)
     @volumes[service_hash[:variables][:name]] = vol
     save_state
   rescue StandardError => e
     p :add_volume_failed
     p service_hash
     log_exception(e)
   end
   
end