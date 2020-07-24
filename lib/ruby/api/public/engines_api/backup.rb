class PublicApi 
  def backup_system_files(out)
    system_api.backup_system_files(out)
  end

  def stream_engine_bundle(engine_name, out)
    system_api.stream_engine_bundle(engine_name, out)
  end
  def restore_engine_bundle(istream, params)
    system_api.restore_engine_bundle(istream, params)
  end

  def backup_system_db(out)
    system_api.backup_system_db(out)
  end

  def backup_system_registry(out)
    system_api.backup_system_registry(out)
  end

  def backup_service_data(service_name, out)
    system_api.backup_service_data(service_name, out)
  end

  def backup_engine_config(engine_name, out)
    system_api.backup_engine_config(engine_name, out)
  end

  def backup_engine_service(service_hash,out)
    engine = loadManagedEngine(service_hash[:parent_engine])
    engine.export_service_data(service_hash, out)
  end

  def engines_services_to_backup(engine_name)
    system_api.engines_services_to_backup(engine_name)
  end

  def restore_registry(out, p)
    system_api.restore_registry(out, p)
  end

  def restore_system_files(out, p)
    system_api.restore_system_files(out, p)
  end

  def restore_engines()
    system_api.restore_engines()
  end
end
