module FileSystemContid
  def fix_containers_fsid(engines)
    engines.each do |engine|
      STDERR.puts(' doing ' + engine.container_name.to_s)
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
    unless fs_hashs.is_a?(Array)
      fs_hashs.each do | service_hash |
        #  next if service_hash[:variables].key?(:fw_user)
       # service_hash[:variables][:fw_user] = engine.cont_user_id
        STDERR.puts('H:' + engine.cont_user_id.to_s)
        begin
          # system_registry_client.update_attached_service(service_hash)
         # STDERR.puts('H:' + service_hash[:variables][:fw_user].to_s )
        rescue StandardError => e
          STDERR.puts(e.to_s)
        end
      end
      end
  end

end