module ManagedContainerExportImportService
  
  def import_service_data(service_hash, istream = nil)  
     container_api.import_service_data(self, service_hash, istream)
   end
#   

 def export_service_data(params, stdout_stream = nil)
   container_api.export_service_data(self, params, stdout_stream)
 end
end