module ServiceImportExport
  
  def export_service(service_hash) 
   r = @core_api.export_service(service_hash)
    return failed(params.to_s, @last_error, 'export service') unless t.is_a?(String) 
    return r 
  end
  
  def import_service(params) 
  return  success(params.to_s,  'import service') if @core_api.import_service(params)
    return failed(params.to_s, @last_error, 'import service')  
     
    end
    

  
end