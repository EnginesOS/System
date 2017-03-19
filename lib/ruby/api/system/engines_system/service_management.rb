module ServiceManagement
  def disable_service(service_name)
    service =  @engines_api.loadManagedService(service_name)
    raise EnginesException.new(error_hash("service container exists", service_name)) unless service.read_state == 'nocontainer'
    FileUtils.mv(ContainerStateFiles.container_service_dir(service_name),ContainerStateFiles.container_disabled_service_dir(service_name))
  end

  def enable_service(service_name)
    #raise EnginesException.new(error_hash("service exists", service_name)) unless
    begin
      @engines_api.loadManagedService(service_name)
      raise EnginesException.new(error_hash("service exists", service_name))
    rescue
      FileUtils.mv(ContainerStateFiles.container_disabled_service_dir(service_name),ContainerStateFiles.container_service_dir(service_name))
    end
  end

end