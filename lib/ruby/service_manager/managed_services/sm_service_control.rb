require_relative 'private/service_container_actions.rb'

class ServiceManager  
  # @ Attach service called by builder and create service
  #if persisttant it is added to the Service Registry Tree
  # @ All are added to the ManagesEngine/Service Tree
  # @ return true if successful or false if failed
  # no_engien used by  service builder it ignore no engine error
  def create_and_register_service(service_hash) # , no_engine = false)
    set_top_level_service_params(service_hash, service_hash[:parent_engine])
    resolve_field_template(service_hash) unless service_hash.frozen?

   # SystemDebug.debug(SystemDebug.services, :sm_create_and_register_service, service_hash)
    #register with Engine
    unless service_hash[:soft_service] == true && ! is_service_persistent?(service_hash)
      system_registry_client.add_to_managed_engines_registry(service_hash)
      # FIXME not checked because of builder createing services prior to engine
     # SystemDebug.debug(SystemDebug.services, :create_and_register_service_register, service_hash)
    end
    unless service_hash.key?(:shared) && service_hash[:shared] == true
      # add to service and register with service
      if is_service_persistent?(service_hash)
       # SystemDebug.debug(SystemDebug.services, :create_and_register_service_persistr, service_hash)
        begin
          add_to_managed_service(service_hash)
        rescue StandardError => e
          STDERR.puts('FAILED TO ADD to Service' + service_hash.to_s)
          system_registry_client.remove_from_managed_engine(service_hash)
          raise e
        end
        system_registry_client.add_to_services_registry(service_hash)
      else
       # SystemDebug.debug(SystemDebug.services, :create_and_register_service_nonpersistr, service_hash)
        add_to_managed_service(service_hash)
        system_registry_client.add_to_services_registry(service_hash)
      end
    end
    true
  end

  def remove_service_from_engine_only(service_query)
    complete_service_query = set_top_level_service_params(service_query, service_query[:parent_engine])
  #  STDERR.puts('delete_service QUERRY ' + service_query.to_s)
    service_hash = retrieve_engine_service_hash(complete_service_query)
    system_registry_client.remove_from_managed_engine(service_hash)
  end
  
  #remove service matching the service_hash from both the managed_engine registry and the service registry
  # @return false
  def delete_and_remove_service(service_query)
    complete_service_query = set_top_level_service_params(service_query, service_query[:parent_engine])
 #   STDERR.puts('delete_service QUERRY ' + service_query.to_s)
    service_hash = retrieve_engine_service_hash(complete_service_query)
    service_hash[:lost] = service_hash[:lost] if service_query.key?(:lost)
    raise EnginesException.new(error_hash('Not Matching Service to remove', complete_service_query)) unless service_hash.is_a?(Hash)
    if service_hash[:shared] == true
      remove_shared_service_from_engine(service_query)
    elsif service_query[:remove_all_data] == 'all' || service_query[:persistent] == false
      begin
        remove_from_managed_service(service_hash) ## continue if
      rescue StandardError => e
        raise e unless service_query.key?(:force) || service_query.key?(:lost) || service_query[:persistent] == false
      end
      begin
        system_registry_client.remove_from_services_registry(service_hash)
      rescue StandardError => e
        raise e unless service_query.key?(:force)
      end
    else
      orphanate_service(service_hash)
   #   STDERR.puts('ORPH SERV data' + service_hash.to_s)
    end
    begin
    system_registry_client.remove_from_managed_engine(service_hash)
    rescue StandardError => e
      STDERR.puts("FAiled to remove from managed engines registry #{service_hash} \n#{e}")
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
  
  private

  def resolve_field_template(service_hash)
    service_vars = service_hash[:variables]
    service_hash[:variables].keys.each do | k|
      next if service_vars[k].nil?
   #   STDERR.puts('fld ' + k.to_s + ' = ' + service_vars[k].to_s + ' is frozen')
      next if service_vars[k].frozen?
      service_vars[k].gsub!(/_Engines_Field\([0-9a-z_A-Z]*\)/) { |match|
        resolve_field_val(match, service_vars)
      }
    end
  end

  def resolve_field_val(fld_name, service_vars)
    begin
    fld = fld_name.sub(/_Engines_Field\(/, '')
    fld.sub!(/[\)]/, '')
    val=''
    unless fld.nil?
      fld = fld.to_sym
      val = service_vars[fld] if service_vars.key?(fld)
    end
    val
end

  end
 
end