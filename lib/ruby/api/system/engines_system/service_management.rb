module ServiceManagement
  def disable_service(service_name)
   service =  @engines_api.loadManagedService(service_name)
   return service if service.is_a?(EnginesError)
   
   return log_error_mesg("service container exists",service_name) unless service.read_state = 'nocontainer'
   STDERR.puts("MOVING" +ContainerStateFiles.container_service_dir(container.container_name).to_s + ' to ' + ContainerStateFiles.container_disabled_service_dir(container.container_name).to_s )    
   FileUtils.mv(ContainerStateFiles.container_service_dir(container.container_name),ContainerStateFiles.container_disabled_service_dir(container.container_name))
     
end

  def enable_service(service_name)
    return log_error_mesg("service exists") unless @engines_api.loadManagedService(service_name).is_a?(EnginesError)
     FileUtils.mv(ContainerStateFiles.container_disabled_service_dir(service_name),ContainerStateFiles.container_service_dir(service_name))
       
  end

end