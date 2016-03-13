module ServiceImportExport
  
  def export_service(service_hash) 
    SystemDebug.debug(SystemDebug.export_import, :export_service,service_hash) 
   r = @core_api.export_service(service_hash)
    return failed(params.to_s, @last_error, 'export service') if r.is_a?(FalseClass) 
    SystemDebug.debug(SystemDebug.export_import, :export_service,r) 
    return r 
  end
  
  def import_service(params) 
    SystemDebug.debug(SystemDebug.export_import, :input_service,params) 
  return  success(params.to_s,  'import service') if @core_api.import_service(params)
    return failed(params.to_s, @last_error, 'import service')  
     
    end
    

  
end