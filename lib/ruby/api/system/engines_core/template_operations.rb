module TemplateOperations
  def fillin_template_for_service_def(service_hash)
    return false unless check_service_hash(service_hash)
    service_def =  SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
    container = loadManagedEngine(service_hash[:parent_engine])
    if container == false
      log_error_mesg('container load error', service_hash)
    else
      SystemDebug.debug(SystemDebug.templater,  :filling_in_template_on, container.container_name)
    end
    templater = Templater.new(SystemAccess.new, container)
    templater.fill_in_service_def_values(service_def)
    #FIXME make service_handle_field unique

    return service_def
  rescue StandardError => e
    p service_hash
    p service_def
    log_exception(e)
  end

  def get_resolved_string(env_value)

    templater = Templater.new(SystemAccess.new,nil)
    env_value = templater.apply_system_variables(env_value)
    return env_value
  rescue StandardError => e

    log_exception(e)
  end
  
  def get_resolved_engine_string(env_value, container)
    templater = Templater.new(SystemAccess.new,container)
        env_value = templater.apply_system_variables(env_value)
        return env_value
      rescue StandardError => e
    
        log_exception(e)
  
  end
  
end