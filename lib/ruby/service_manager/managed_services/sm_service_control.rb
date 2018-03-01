require_relative 'private/service_container_actions.rb'
module SmServiceControl
  # @ Attach service called by builder and create service
  #if persisttant it is added to the Service Registry Tree
  # @ All are added to the ManagesEngine/Service Tree
  # @ return true if successful or false if failed
  # no_engien used by  service builder it ignore no engine error
  def create_and_register_service(service_hash) # , no_engine = false)
    set_top_level_service_params(service_hash, service_hash[:parent_engine])
    SystemDebug.debug(SystemDebug.services, :sm_create_and_register_service, service_hash)
    resolve_field_template(service_hash)
    #register with Engine
    unless service_hash[:soft_service] == true && ! is_service_persistent?(service_hash)
      system_registry_client.add_to_managed_engines_registry(service_hash)
      # FIXME not checked because of builder createing services prior to engine
      SystemDebug.debug(SystemDebug.services, :create_and_register_service_register, service_hash)
    end
    unless service_hash.key?(:shared) && service_hash[:shared] == true
      # add to service and register with service
      if is_service_persistent?(service_hash)
        SystemDebug.debug(SystemDebug.services, :create_and_register_service_persistr, service_hash)
        begin
          add_to_managed_service(service_hash)
        rescue StandardError => e
          STDERR.puts('FAILED TO ADD to Service' + service_hash.to_s)
          system_registry_client.remove_from_managed_engine(service_hash)
          raise e
        end
        system_registry_client.add_to_services_registry(service_hash)
      else
        SystemDebug.debug(SystemDebug.services, :create_and_register_service_nonpersistr, service_hash)
        add_to_managed_service(service_hash)
        system_registry_client.add_to_services_registry(service_hash)
      end
    end
    true
  end

  #remove service matching the service_hash from both the managed_engine registry and the service registry
  # @return false
  def delete_and_remove_service(service_query)
    complete_service_query = set_top_level_service_params(service_query, service_query[:parent_engine])
      STDERR.puts('delete_service QUERRY ' + service_query.to_s)
      service_hash = retrieve_engine_service_hash(complete_service_query)
    raise EnginesException.new(error_hash('Not Matching Service to remove', complete_service_query)) unless service_hash.is_a?(Hash)
    if service_hash[:shared] == true
      remove_shared_service_from_engine(service_query)
    elsif service_query[:remove_all_data] == 'all'
      begin
        remove_from_managed_service(service_hash) ## continue if
      rescue StandardError => e
        raise e unless service_query.key?(:force)
      end
      begin
        system_registry_client.remove_from_managed_engine(service_hash)
        remove_from_managed_service(service_hash) ## continue if
      rescue StandardError => e
        raise e unless service_query.key?(:force)
      end
      begin
        system_registry_client.remove_from_services_registry(service_hash)
      rescue StandardError => e
        raise e unless service_query.key?(:force)
      end
    else
      orphanate_service(service_hash)
      STDERR.puts('ORPH SERV data' + service_hash.to_s)
    end
  end

  def update_attached_service(params)
    set_top_level_service_params(params, params[:parent_engine])
    if params[:persistent] == false
      system_registry_client.update_attached_service(params)
      remove_from_managed_service(params)
      add_to_managed_service(params)
    else
      update_persistent_service(params)
    end
  end

  def update_persistent_service(params)
    set_top_level_service_params(params, params[:parent_engine])
    # FIXME: check if variables are editable
    extisting_variables = retrieve_engine_service_hash(params)[:variables]
    # STDERR.puts('UPDATing to ' + extisting_variables.to_s)
    # STDERR.puts('UP DATEONG WITH  ' + params.to_s)
    params[:variables] = extisting_variables.merge!(params[:variables])
    update_on_managed_service(params)
    # STDERR.puts('UPDAED ' + params.to_s)
    system_registry_client.update_attached_service(params)
  end
 
  def clear_service_from_registry(service) 
    system_registry_client.clear_service_from_registry(service)
  rescue EnginesException => e
    raise e unless e.level == :warning
  end
  
  def resolve_field_template(service_hash)
    STDERR.puts('RESOLVING ' + service_hash.to_s)
    def resolve_field_val(fld_name)
      STDERR.puts('RESOLVE FLD ' + fld_name.to_s)
      val=''
      unless fld_name.nil?
        fld_name = fld_name.to_sym
        if service_hash[:variables].key?(fld_name)
          val = service_hash[:variables][fld_name]
      end
    end
    val
    end
    service_hash[:variables].keys do | k|
      v = service_hash[:variables][k]
        STDERR.puts('TEMPLATEING Valu ' +  v.to_s)
      next if v.nil?
      v.gsub!(/_Engines_Fields\([0-9a-z_A-Z]\)/) { |match|
        service_hash[:variables][k] = resolve_field_val(match)
           }
    end
  
  end

end