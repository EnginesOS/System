module ManagedServiceImportExport
  def import_data(ins)
    @container_api.service_restore(self, ins, {})
  end

  def export_data(out)
    @container_api.export_data(self, out)
  end

  def export_service_data(service_hash, out)
    @container_api.export_service_data(self,service_hash, out)
  end

  def import_service_data(service_hash, ins)
    @container_api.import_service_data(self,service_hash, ins)
  end
end