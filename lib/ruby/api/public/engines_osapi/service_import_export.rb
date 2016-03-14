module ServiceImportExport
  
  def export_service(service_hash) 
    SystemDebug.debug(SystemDebug.export_import, :export_service,service_hash) 
   r = @core_api.export_service(service_hash)
    return failed(service_hash.to_s, @last_error, 'export service') if r.is_a?(FalseClass)    
    return r 
  end
  
  def import_service(params) 
    
    #SystemUtils.symbolize_keys(params)
    SystemUtils.deal_with_jason(params)
  return  success(params.to_s,  'import service') if @core_api.import_service(params)
    return failed(params.to_s, @last_error, 'import service')  
     
    end
    

  
end