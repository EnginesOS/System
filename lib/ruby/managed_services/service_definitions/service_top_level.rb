def set_top_level_service_params(service_hash, container_name)
  container_name = service_hash[:parent_engine] if service_hash.key?(:parent_engine)
  container_name = service_hash[:engine_name] if container_name == nil
  return log_error_mesg('no set_top_level_service_params_nil_service_hash container_name:', container_name) if container_name.nil?
  return log_error_mesg('no set_top_level_service_params_nil_container_name service_hash:', service_hash)  if service_hash.nil?
  service_def = software_service_definition(service_hash)
  return service_def if service_def.is_a?(EnginesError)
  service_hash[:service_container_name] = service_def[:service_container]
  service_hash[:persistent] = service_def[:persistent]
  service_hash[:parent_engine] = container_name
  service_hash[:container_type] = 'container' if service_hash.has_key?(:container_type) == false || service_hash[:container_type] ==nil
  service_hash[:variables] = {} unless service_hash.has_key?(:variables)
  service_hash[:variables][:parent_engine] = container_name
  if service_def.key?(:priority)
    service_hash[:priority] = service_def[:priority]
  else
    service_hash[:priority] = 0
  end
  return service_hash if service_hash.key?(:service_handle) && ! service_hash[:service_handle].nil?

  if service_def.key?(:service_handle_field) && !service_def[:service_handle_field].nil?
    handle_field_sym = service_def[:service_handle_field].to_sym
    return log_error_mesg('Missing Service Handle field in variables', handle_field_sym) unless service_hash[:variables].key?(handle_field_sym)
    service_hash[:service_handle] = service_hash[:variables][handle_field_sym]
  else
    service_hash[:service_handle] = container_name
  end

  service_hash
rescue StandardError => e
  SystemUtils.log_exception(e)
end

def is_soft_service?(service_hash)
  soft = SoftwareServiceDefinition.is_soft_service?(service_hash)
  return log_error_mesg('Failed to get software status for ', service_hash) if soft.nil?
  service_hash[:soft_service] = soft
  service_hash[:soft_service]
rescue StandardError => e
  log_exception(e)
end

def is_service_persistent?(service_hash)
  #  alway s check dont trust service_hash
  persist = software_service_persistence(service_hash)
  return log_error_mesg('Failed to get persistence status for ', service_hash)  if persist.nil?
  service_hash[:persistent] = persist
  service_hash[:persistent]
rescue StandardError => e
  log_exception(e)
end

def software_service_definition(params)
  SoftwareServiceDefinition.find(params[:type_path], params[:publisher_namespace] )
rescue Exception=>e
end

def software_service_persistence(service_hash)
  service_definition = software_service_definition(service_hash)
  return service_definition[:persistent] unless service_definition.nil?
  nil
rescue StandardError => e
  log_exception(e)
end

def get_software_service_container_name(params)
  SoftwareServiceDefinition.get_software_service_container_name(params)
rescue StandardError => e
  STDERR.puts('PARAMS ' + params.to_s)
  SystemUtils.log_exception(e,params)
end