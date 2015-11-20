module ServiceHashChecks
  def check_engine_hash(service_hash)
    return false unless check_hash(service_hash)
    # FIXME: Kludge
    # Klugde to avoid gui bugss
    unless service_hash.key?(:parent_engine)
      service_hash[:parent_engine] = service_hash[:engine_name]
    end
    service_hash[:container_type] = "container" unless service_hash.key?(:container_type)
    # End of Kludge
    return log_error_mesg('No parent engine', service_hash) unless service_hash.key?(:parent_engine)
    return log_error_mesg('nil parent_engine', service_hash) if service_hash[:parent_engine].nil? || service_hash[:parent_engine] == ''
    return log_error_mesg('No container type path', service_hash) unless service_hash.key?(:container_type)
    return log_error_mesg('nil container type path', service_hash)  if service_hash[:container_type].nil? || service_hash[:container_type] == ''
    return true
  end

  def check_sub_service_hash(service_hash)
    return false unless check_service_hash(service_hash)
    return log_error_mesg('No parent service', service_hash) unless service_hash.key?(:parent_service)
    return true
  end

  def check_engine_service_hash(service_hash)
    return false unless check_engine_service_query(service_hash)
    return log_error_mesg('No service variables', service_hash) unless service_hash.key?(:variables)
    return true
  end

  def check_engine_service_query(service_hash)
    return false unless check_service_hash(service_hash)
    return false unless check_engine_hash(service_hash)
    return true
  end

  def check_hash(service_hash)
    return log_error_mesg('Nil service Hash', service_hash) if service_hash.nil?
    return log_error_mesg('Not a Service Hash', service_hash) unless service_hash.is_a?(Hash)
    return true
  end

  def check_service_hash(service_hash)
    return false unless check_hash(service_hash)
    return log_error_mesg('No publisher name space', service_hash) unless service_hash.key?(:publisher_namespace)
    return log_error_mesg('nil publisher name space', service_hash) if service_hash[:publisher_namespace].nil? || service_hash[:publisher_namespace] == ''
    return log_error_mesg('No type path', service_hash) unless service_hash.key?(:type_path)
    return log_error_mesg('nil type path', service_hash) if service_hash[:type_path].nil? || service_hash[:type_path] == ''

    return true
  end

end