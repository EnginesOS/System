module ServiceImportExport
  
  def export_service(service_hash) 
    engines_core.export_service(service_hash) 
  end
  
  def import_service(service_hash, data) 
      engines_core.import_service(service_hash) 
    end
    

  
end