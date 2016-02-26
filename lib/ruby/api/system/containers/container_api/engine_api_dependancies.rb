module EngineApiDependancies

  def start_dependancies(container)
    return true unless container.dependant_on.is_a?(Array)
    container.dependant_on.each do |service_name|
      SystemDebug.debug(SystemDebug.containers, :checking_depends,  service_name)
      service = engines_core.loadManagedService(service_name)
      return log_error_mesg('Failed to load ', service_name) unless service
      unless service.is_running?
        if service.has_container?
          if service.is_active?
            return log_error_mesg('Failed to unpause ', service_name) if !service.unpause_container
          else
            return log_error_mesg('Failed to start ', service_name) if !service.start_container
          end
          return log_error_mesg('Failed to create ', service_name) if !service.create_container
        end
      end
      retries = 0
      while !has_service_started?(service_name)
        sleep 2
        retries += 1
        return log_error_mesg('Time out in waiting for Service Dependancy ' + service_name + ' to start ', service_name) if retries > 150
      end
    end
    return true
  end
end