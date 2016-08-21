module ManagedContainerExportImportService
  
  def import_service_data(service_hash)  
     @container_api.import_service_data(self, service_hash)
   end
#   
#  def import_replace_service_data(params)
#    @container_api.import_replace_service_data(params)
#  end
  
 def export_service_data(params, ostream)
   @container_api.export_service_data(self, params, ostream)
 end
end