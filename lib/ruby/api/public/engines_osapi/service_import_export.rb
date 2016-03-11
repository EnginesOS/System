module ServiceImportExport
  
  def export_service(service_hash) 
    @core_api.export_service(service_hash) 
  end
  
  def import_service(service_hash, data) 
    @core_api.import_service(service_hash) 
    end
    

  
end