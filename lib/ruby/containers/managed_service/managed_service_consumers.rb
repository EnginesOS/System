module ManagedServiceConsumers
  
  def remove_consumer(service_hash)
    return log_error_mesg('remove consumer nil service hash ', '') if service_hash.nil?
    return true if !is_running? && @soft_service
    return log_error_mesg('Cannot remove consumer if Service is not running ', service_hash) unless is_running?
    return log_error_mesg('service missing cont_userid ', service_hash) if check_cont_uid == false
    return rm_consumer_from_service(service_hash) unless @persistant
    return rm_consumer_from_service(service_hash) if service_hash.has_key?(:remove_all_data)  && service_hash[:remove_all_data]
    log_error_mesg('Not persitant or service hash missing remove data',service_hash)
  end

  #  def service_manager
  #    return @container_api.service_manager
  #  end

  def registered_consumers
    params = {}
    params[:publisher_namespace] = @publisher_namespace
    params[:type_path] = @type_path
    @container_api.get_registered_against_service(params)
  end

  def reregister_consumers
    return true if @persistant == true
    return log_error_mesg('Cant register consumers as not running ',self)  if is_running? == false
    registered_hashes = registered_consumers
    return true if registered_hashes == nil
    registered_hashes.each do |service_hash|
      add_consumer_to_service(service_hash) if service_hash[:persistant] == false
    end
    return true
  end

  def add_consumer(service_hash)
    return log_error_mesg('add consumer passed nil service_hash ','') unless service_hash.is_a?(Hash)
    service_hash[:persistant] = @persistant
    result = false
    # add/create persistant if fresh == true on not at all or if running create for no persistant
    return true if !is_running? && @soft_service

    return log_error_mesg('service not running' ,self) unless is_running?
    unless @persistant
      result = add_consumer_to_service(service_hash)
    else
      if service_hash.key?(:fresh) && service_hash[:fresh] == false
        result = true
      else
        service_hash[:fresh] = false  if service_hash[:persistant] == true
        result = add_consumer_to_service(service_hash)
      end
    end

    #note we add to service regardless of whether the consumer is already registered
    #for a reason
    return result unless result
    save_state
    return result
  end

  private

  def  add_consumer_to_service(service_hash)
  
    return log_error_mesg('service missing cont_userid ',service_hash) unless check_cont_uid
    @container_api.add_consumer_to_service(self, service_hash)
  end

  def rm_consumer_from_service(service_hash)
    return log_error_mesg('service startup not complete ',service_hash) unless is_startup_complete?
    @container_api.rm_consumer_from_service(self, service_hash)
  end


end