module ServiceManagerOperations
  def register_non_persistant_services(engine)
    service_manager.register_non_persistant_services(engine)
  end

  def deregister_non_persistant_services(engine)
    service_manager.deregister_non_persistant_services(engine)
  end

  def load_and_attach_services(dirname, container)
    service_manager.load_and_attach_services(dirname, container)
  end

  def get_service_configuration(service_param)
    service_manager.get_service_configuration(service_param)
  end

  def check_sm_result(result)
    @last_error = service_manager.last_error.to_s if result.nil? || result.is_a?(FalseClass)
    return result
  end

end