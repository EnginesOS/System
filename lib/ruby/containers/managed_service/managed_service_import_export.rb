module ManagedServiceImportExport
  def import_data(ins)
    container_dock.service_restore(self, ins, {})
  end

  def export_data(out)
    container_dock.export_data(self, out)
  end

  def export_service_data(service_hash, out)
    container_dock.export_service_data(self, service_hash, out)
  end

  def import_service_data(service_hash, ins)
    container_dock.import_service_data(self, service_hash, ins)
  end
end