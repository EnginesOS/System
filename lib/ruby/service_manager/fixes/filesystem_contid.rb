module FileSystemContid

  def fix_containers_fsid(engines)
    engines.each do |engine|
      fix_fs_cont_id(engine)
    end
  end
  
  def fix_fs_cont_id(engine)
    params = {
      parent_engine: engine.container_name, 
      container_type: engine.ctype,
        publisher_namespace: 'EnginesSystem', 
        type_path: 'filesystem/local/filesystem' 
    }
    fs_hashs = system_registry_client.find_engine_services_hashes(params)
    fs_hashs.each do | service_hash |
      next if service_hash[:variables].key?(:fw_user)
      service_hash[:variables][:fw_user] = engine.cont_user_id
     begin
     # system_registry_client.update_attached_service(service_hash)
       STDERR.puts('H:' + service_hash.to_s )
        rescue StandardError => e
          STDERR.puts(e.to_s)
        end
    end
    
end


end