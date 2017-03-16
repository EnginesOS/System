module TemplateOperations
  def system_value_access
    return @system_value_accessor unless @system_value_accessor.nil?
    @system_value_accessor = SystemAccess.new(self)
    @system_value_accessor
  end

  def fillin_template_for_service_def(service_hash)
    check_service_hash(service_hash)
    service_def =  SoftwareServiceDefinition.find(service_hash[:type_path], service_hash[:publisher_namespace])
    container = loadManagedEngine(service_hash[:parent_engine])
    return container if container.is_a?(EnginesError)
    templater = Templater.new(system_value_access, container)
    templater.fill_in_service_def_values(service_def)
    #FIXME make service_handle_field unique
    service_def
  rescue StandardError => e
    p service_hash
    p service_def
    log_exception(e)
  end

  def get_resolved_string(env_value)
    templater = Templater.new(system_value_access,nil)
    env_value = templater.apply_system_variables(env_value)
    env_value
  rescue StandardError => e
    log_exception(e)
  end

  def get_resolved_engine_string(env_value, container)
    templater = Templater.new(system_value_access,container)
    value = templater.apply_build_variables(env_value)
    SystemDebug.debug(SystemDebug.templater,  ' get_resolved_engine_string ' + value.to_s + 'from ', env_value)
    value
  rescue StandardError => e
    log_exception(e,env_value,container)
  end

end