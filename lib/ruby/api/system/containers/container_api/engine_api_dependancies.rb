module EngineApiDependancies
  def start_dependancies(container)
    SystemDebug.debug(SystemDebug.containers, :checking_depends,container.dependant_on)
    return true unless container.dependant_on.is_a?(Array)
    container.dependant_on.each do |service_name|
      SystemDebug.debug(SystemDebug.containers, :checking_depends,  service_name)
      service = engines_core.loadManagedService(service_name)
      unless service.is_running?
        if service.has_container?
          if service.is_active?
            raise EnginesException.new(error_hash('Failed to unpause ', service_name)) if !service.unpause_container
          else
            raise EnginesException.new(error_hash('Failed to start ', service_name)) if !service.start_container
          end
          raise EnginesException.new(error_hash('Failed to create ', service_name)) if !service.create_container
        end
      end
      retries = 0
      # FixME
      # use event queue
      while !has_service_started?(service_name)
        sleep 0.2
        retries += 1
        raise EnginesException.new(error_hash('Time out in waiting for Service Dependancy ' + service_name + ' to start ', service_name)) if retries > 20
      end
    end
  end
end