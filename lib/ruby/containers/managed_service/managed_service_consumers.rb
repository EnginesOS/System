module ManagedServiceConsumers
  def remove_consumer(service_hash)
    raise EnginesException.new(error_hash('Invalid service hash ', service_hash)) unless service_hash.is_a?(Hash)
    return true if !is_running? && @soft_service
    raise EnginesException.new(error_hash('Cannot remove consumer if Service is not running ', service_hash)) unless is_running?
    raise EnginesException.new(error_hash('service missing cont_user_id ', service_hash)) if check_cont_uid == false
    rm_consumer_from_service(service_hash)
  end

  def registered_consumers(params = nil)
    if params.nil?
      params = {
        publisher_namespace: @publisher_namespace,
        type_path: @type_path
      }
      alias_services = nil
      unless @aliases.nil?
        if @aliases.is_a?(Array)
          @aliases.each do |type_path|
            alias_services ||= []
            params[:type_path] = type_path
            reg = container_api.get_registered_consumer(params)
            alias_services += reg if reg.is_a?(Array)
          end
        end
      end
      unless alias_services.nil?
        params[:type_path] = @type_path
        reg_services =   container_api.registered_with_service(params)
        alias_services += reg_services if reg_services.is_a?(Array)
        return alias_services
      end
      container_api.registered_with_service(params)
    else
      registered_consumer(params)
    end
  end

  def registered_consumer(params)
    service_params = {
      publisher_namespace: @publisher_namespace,
      type_path: @type_path,
      parent_engine: params[:parent_engine]
    }
    service_params[:service_handle] = params[:service_handle] if params.key?(:service_handle)

    container_api.get_registered_consumer(service_params)
  end

  def reregister_consumers
    if @persistent == true && @soft_service == false
      true
    else
      if is_running? == true
        # raise EnginesException.new(error_hash('Cant register consumers as not running ', self.container_name))  if is_running? == false
        registered_hashes = registered_consumers
        if registered_hashes.is_a?(Array)
          registered_hashes.each do |service_hash|
            begin
      #        STDERR.puts('add consume ' + service_hash.to_s)
              add_consumer_to_service(service_hash) if service_hash[:persistent] == false
            rescue StandardError => e
              STDERR.puts('add consumer error:' + e.to_s)
              next
            end
          end
        end
      else
        false
      end
    end
  end

  def add_consumer(service_hash)
    raise EnginesException.new(error_hash('Invalid service_hash ', service_hash)) unless service_hash.is_a?(Hash)
    service_hash[:persistent] = @persistent unless service_hash.key?(:persistent)
    result = false
    # add/create persistent if fresh == true on not at all or if running create for no persistent
    return true if !is_running? && @soft_service
    raise EnginesException.new(error_hash('service not running', @container_name)) unless is_running?
    unless service_hash[:persistent]
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
    save_state if result
    result
  end

  def update_consumer(service_hash)
    raise EnginesException.new(error_hash('service missing cont_user_id '+ container_name, service_hash)) unless check_cont_uid
    raise EnginesException.new(error_hash('service startup not complete ' + container_name, service_hash)) unless is_startup_complete?
    container_api.update_consumer_on_service(self, service_hash)
  end

  private

  def add_consumer_to_service(service_hash)
    raise EnginesException.new(error_hash('service missing cont_user_id '+ container_name, service_hash)) unless check_cont_uid
    unless is_startup_complete?
     # STDERR.puts('START UP BOT CPMPLEYE ' )
    #  STDERR.puts('soft_service' + @soft_service.to_s)
      unless @soft_service == true
        raise EnginesException.new(error_hash('service startup not complete ' + container_name, service_hash))
      end
    end
    container_api.add_consumer_to_service(self, service_hash)
  end

  def rm_consumer_from_service(service_hash)
    raise EnginesException.new(error_hash('service startup not complete ' + container_name,service_hash)) unless is_startup_complete?
    container_api.rm_consumer_from_service(self, service_hash)
  end

end
