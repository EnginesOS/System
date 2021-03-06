class SystemApi
  def disable_service(service_name)
    service =  core.loadManagedService(service_name)
    raise EnginesException.new(error_hash("service container exists", service_name)) if service.has_container?
    FileUtils.mv(container_service_dir(service_name), ContainerStateFiles.container_disabled_service_dir(service_name))
  end

  def enable_service(service_name)
    begin
      core.loadManagedService(service_name)
      raise EnginesException.new(error_hash("service exists", service_name))
    rescue
      FileUtils.mv(ContainerStateFiles.container_disabled_service_dir(service_name), ContainerStateFiles.container_service_dir(service_name))
    end
  end
end
