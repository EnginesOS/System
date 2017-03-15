require_relative 'private/service_container_actions.rb'

module SmOrphanServices
  def orphanate_service(params)
    SystemDebug.debug(SystemDebug.orphans, :Orphanate, params)
    params[:fresh] = false
    system_registry_client.orphanate_service(params)
  rescue StandardError => e
    handle_exception(e)
  end

  ## ????
  def release_orphan(params)
    SystemDebug.debug(SystemDebug.orphans, :release_orphan, params)
    system_registry_client.release_orphan(params)
  rescue StandardError => e
    handle_exception(e)
  end

  def rollback_orphaned_service(service_hash)
    SystemDebug.debug(SystemDebug.orphans, :rollback_orphaned_service, service_hash)
    system_registry_client.rollback_orphaned_service(service_hash)
  rescue StandardError => e
    handle_exception(e)
  end

  #@returns [Hash] suitable for use  to attach as a service

  def reparent_orphan(service_hash,engine_name )
    service_hash[:old_parent] =  service_hash[:parent_engine]
    service_hash[:parent_engine] = engine_name
    service_hash[:fresh] = false
    service_hash[:freed_orphan] = true
    #resuse_service_hash = @service_manager.reparent_orphan(service_hash)
    service_hash
  rescue StandardError => e
    handle_exception(e)
  end

  def match_orphan_service(service_hash)
    res =  retrieve_orphan(service_hash)
    # STDERR.puts(" MATCHED  " + res.to_s)
    if res.is_a?(Hash)
      return true if res[:publisher_namespace] == service_hash[:publisher_namespace]
    end
    false
  rescue StandardError => e
    handle_exception(e)
  end

  def retrieve_orphan(params)
    system_registry_client.retrieve_orphan(params)
  rescue StandardError => e
    handle_exception(e)
  end

  #@ removes underly service and remove entry from orphaned services
  #@returns boolean indicating success
  def remove_orphaned_service(service_query_hash)
    SystemDebug.debug(SystemDebug.orphans, :remove_orphaned_service, service_query_hash)
    clear_error
    service_hash = retrieve_orphan(service_query_hash)
    if service_query_hash[:remove_all_data] == false
      service_hash[:remove_all_data] = false
    else
      service_hash[:remove_all_data] = true
    end
    remove_from_managed_service(service_hash)
    return system_registry_client.release_orphan(service_hash)
  rescue StandardError => e
    handle_exception(e)
  end

  #@return an [Array] of service_hashs of Orphaned persistent services matching @params [Hash]
  # required keys
  # :publisher_namespace
  # optional
  #:path_type
  #@return's nil on failure with error accessible from this object's  [ServiceManager] last_error method
  #on recepit of an empty array any non critical error will be in  this object's  [ServiceManager] last_error method
  def get_orphaned_services(params)
    system_registry_client.get_orphaned_services(params)
  rescue StandardError => e
    handle_exception(e)
  end

  def connect_orphan_service(service_hash)
    orphan_search = service_hash.dup
    orphan_search[:parent_engine] = orphan_search[:owner]
    orphan = retrieve_orphan(orphan_search)
    merge_variables(service_hash,orphan)
    service_hash = reparent_orphan(service_hash, service_hash[:parent_engine])
    create_and_register_service(service_hash)
    release_orphan(orphan)
  rescue StandardError => e
    handle_exception(e)
  end

end