module ServiceManagement
  def disable_service(service_name)
    service =  @engines_api.loadManagedService(service_name)
    raise EnginesException.new(error_hash("service container exists", service_name)) if service.has_container?
    FileUtils.mv(container_service_dir(service_name), container_disabled_service_dir(service_name))
  end

  def enable_service(service_name)
    #raise EnginesException.new(error_hash("service exists", service_name)) unless
    begin
      @engines_api.loadManagedService(service_name)
      raise EnginesException.new(error_hash("service exists", service_name))
    rescue
      FileUtils.mv(container_disabled_service_dir(service_name), container_service_dir(service_name))
    end
  end

end