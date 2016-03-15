module ManagedServiceActions
  # @returns [EnginesOSapiResult]
  # expects a service_hash as @params
  def dettach_service(params)
    SystemDebug.debug(SystemDebug.services,:dettach_service, params)
    return success(params[:parent_engine].to_s, 'detach service') if @core_api.dettach_service(params)
    failed(params[:parent_engine].to_s,@core_api.last_error, params[:parent_engine].to_s)
    rescue StandardError => e
      log_exception_and_fail('dettach_service', e)
  end

  # @return  an [Array] of service_hashes regsitered against the Service named service name
  # wrapper for gui programs calls get_registered_against_service(params)
  def registered_engines_on_service(service_name)
    r_service = getManagedService(service_name)
    return failed(service_name, 'No Such Service', 'list registered Service') if r_service.nil? || r_service.is_a?(EnginesOSapiResult)
    params = {}
    params[:type_path] = r_service.type_path
    params[:publisher_namespace] = r_service.publisher_namespace
    @core_api.get_registered_against_service(params)
    rescue StandardError => e
      log_exception_and_fail('registered_engines_on_service', e)
  end

  # @return an [Array] of service_hashes regsitered against the Service params[:publisher_namespace] params[:type_path]
  def get_registered_against_service(params)
    @core_api.get_registered_against_service(params)
    rescue StandardError => e
      log_exception_and_fail('get_registered_against_service', e)
  end

  # @return an [Array] of service_hashs of Active persistent services match @params [Hash]
  # :path_type :publisher_namespace
  def get_active_persistent_services(params)
    @core_api.get_active_persistent_services(params)
    rescue StandardError => e
      log_exception_and_fail('get_active_persistent_services', e)
  end

  # @return an [Array] of service_hashs of Orphaned persistent services match @params [Hash]
  # :path_type :publisher_namespace
  def get_orphaned_services(params)
    @core_api.get_orphaned_services(params)
    rescue StandardError => e
      log_exception_and_fail('get_orphaned_services', e)
  end

  def update_attached_service(params)
    return success(params[:service_handle], 'update attached Service') if @core_api.update_attached_service(params)
    failed(params[:service_handle], @core_api.last_error, 'update_attached_service')
    rescue StandardError => e
      log_exception_and_fail('update_attached_service', e)
  end

  def delete_orphaned_service(params)
    return success(params[:service_handle], 'Delete Service') if @core_api.remove_orphaned_service(params)
    SystemUtils.log_error_mesg('Delete Orphan Service ' + @core_api.last_error.to_s, params)
    failed(params[:service_handle], @core_api.last_error, 'Delete Orphan Service')
  rescue StandardError => e
    log_exception_and_fail('delete_orphaned_service', e)
  end

  def find_service_consumers(params)
    @core_api.find_service_consumers(params)
    rescue StandardError => e
      log_exception_and_fail('find_service_consumers', e)
  end

  # @ returns  complete service hash matching PNS,SP,PE,SH
  def  retrieve_service_hash(query_hash)
    SystemDebug.debug(SystemDebug.services, query_hash)
    s = @core_api.retrieve_service_hash(query_hash)
    return failed(query_hash[:parent_engine],@core_api.last_error, query_hash.to_s) if s.is_a?(FalseClass)
    return s
    rescue StandardError => e
      log_exception_and_fail('retrieve_service_hash', e)
  end

  def get_engine_persistent_services(params)
    @core_api.get_engine_persistent_services(params)
  rescue StandardError => e
    log_exception_and_fail('get_engine_persistent_services', e)
  end

  # @returns [EnginesOSapiResult]
  # expects a service_hash as @params
  def attach_service(params)
    return success(params[:parent_engine], 'attach service') if @core_api.create_and_register_service(params)
    failed(params[:parent_engine], @core_api.last_error, params[:parent_engine])
    rescue StandardError => e
      log_exception_and_fail('attach_service', e)
  end

  def attach_existing_service_to_engine(params)
    SystemDebug.debug(SystemDebug.services,'attach existing service', params)
    return success(params[:parent_engine], 'attach existing service') if  @core_api.attach_existing_service_to_engine(params)
        failed(params[:parent_engine], @core_api.last_error, params[:parent_engine])
  
    rescue StandardError => e
      log_exception_and_fail('attach_existing_service_to_engine', e)
  end

end