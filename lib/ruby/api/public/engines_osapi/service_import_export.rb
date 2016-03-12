module ServiceImportExport
  
  def export_service(service_hash) 
    @core_api.export_service(service_hash) 
  end
  
  def import_service(params) 
    @core_api.import_service(params) 
    end
    

  
end