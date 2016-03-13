module ManagedContainerExportImportService
  
  def import_service(service_hash)  
     @container_api.import_service(service_hash)
   end
   
 def export_service(service_hash)
   @container_api.export_service(service_hash)
 end
end