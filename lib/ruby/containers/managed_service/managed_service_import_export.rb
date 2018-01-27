module ManagedServiceImportExport
  def import_data(ins)
    @container_api.service_restore(self, ins, {})
  end
  
  def export_data(out)   
    @container_api.export_data(self, out)
  end
end