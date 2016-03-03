module SubserviceActions
  # service params and component objectname / and component name and parent name
  def attach_subservice(params)
    SystemDebug.debug(SystemDebug.services,:attach_subservice, params)
    #    return success(params[:service_handle], 'attach subservice') if @core_api.attach_subservice(params)
    #    SystemUtils.log_error_mesg('attach subservice', params)
    failed(params, @core_api.last_error, 'attach subservice')
  end

  def dettach_subservice(params)
    SystemDebug.debug(SystemDebug.services, :attach_subservice, params)
    #    return success(params[:service_handle], 'attach subservice') if @core_api.dettach_subservice(params)
    #    SystemUtils.log_error_mesg('attach subservice', params)
    failed(params[:service_handle], @core_api.last_error, 'attach subservice')
  end

end