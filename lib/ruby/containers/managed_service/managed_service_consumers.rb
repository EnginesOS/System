module ManagedServiceConsumers
  def remove_consumer(service_hash)
    raise EnginesException.new(error_hash('Invalid service hash ', service_hash)) unless service_hash.is_a?(Hash)
    return true if !is_running? && @soft_service
    raise EnginesException.new(error_hash('Cannot remove consumer if Service is not running ', service_hash)) unless is_running?
    raise EnginesException.new(error_hash('service missing cont_userid ', service_hash)) if check_cont_uid == false
    return rm_consumer_from_service(service_hash) unless @persistent
    return orphanate_service(service_hash) if service_hash.has_key?(:remove_all_data) && service_hash[:remove_all_data] == false
    return rm_consumer_from_service(service_hash) if service_hash.has_key?(:remove_all_data) && service_hash[:remove_all_data]
    true
  end

  def registered_consumers(params = nil)
    if params.nil?
      params = {
      publisher_namespace: @publisher_namespace,
      type_path: @type_path
      }
       @container_api.registered_with_service(params)
    end    
    registered_consumer(params)   
  end

  def registered_consumer(params)
    service_params = {
    publisher_namespace: @publisher_namespace,
    type_path: @type_path,
    parent_engine: params[:parent_engine]
    }
    service_params[:service_handle] = params[:service_handle] if params.key?(:service_handle)
    @container_api.get_registered_consumer(service_params)
  end

  def reregister_consumers
    return true if @persistent == true
    raise EnginesException.new(error_hash('Cant register consumers as not running ', self.container_name))  if is_running? == false
    registered_hashes = registered_consumers
    return true unless registered_hashes.is_a?(Array)
    registered_hashes.each do |service_hash|      
      add_consumer_to_service(service_hash) if service_hash[:persistent] == false
    end
     true
  end

  def add_consumer(service_hash)
    raise EnginesException.new(error_hash('Invalid service_hash ',  service_hash)) unless service_hash.is_a?(Hash)
    service_hash[:persistent] = @persistent
    result = false
    # add/create persistent if fresh == true on not at all or if running create for no persistent
    return true if !is_running? && @soft_service

    raise EnginesException.new(error_hash('service not running' , @container_name)) unless is_running?
    unless @persistent
      result = add_consumer_to_service(service_hash)
    else
      if service_hash.key?(:fresh) && service_hash[:fresh] == false
        result = true
      else
        service_hash[:fresh] = false if service_hash[:persistent] == true
        result = add_consumer_to_service(service_hash)
      end
    end

    #note we add to service regardless of whether the consumer is already registered
    #for a reason
    return result unless result
    save_state
     result
  end

  private

  def add_consumer_to_service(service_hash) 
    raise EnginesException.new(error_hash('service missing cont_userid '+ container_name, service_hash)) unless check_cont_uid
    raise EnginesException.new(error_hash('service startup not complete ' + container_name, service_hash)) unless is_startup_complete?
    @container_api.add_consumer_to_service(self, service_hash)
  end

  def rm_consumer_from_service(service_hash)
    raise EnginesException.new(error_hash('service startup not complete ' + container_name,service_hash)) unless is_startup_complete?
    @container_api.rm_consumer_from_service(self, service_hash)
  end

end