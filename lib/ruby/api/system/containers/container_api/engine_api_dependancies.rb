module EngineApiDependancies
  def start_dependancies(container)
    started = 0
    SystemDebug.debug(SystemDebug.containers, :checking_depends,container.dependant_on)
    if container.dependant_on.is_a?(Array)
      container.dependant_on.each do |service_name|
        SystemDebug.debug(SystemDebug.containers, :checking_depends,  service_name)
        service = engines_core.loadManagedService(service_name)
        unless service.is_running?
          started += 1
          if service.has_container?
            if service.is_active?
              raise EnginesException.new(error_hash('Failed to unpause ', service_name))  unless service.unpause_container
            else
              raise EnginesException.new(error_hash('Failed to start ', service_name)) unless service.start_container
            end
          else
            raise EnginesException.new(error_hash('Failed to create ', service_name)) unless service.create_service
          end
        end
        raise EnginesException.new(error_hash('Time out in waiting for Service Dependancy to start' + service_name + ' to start ', service_name)) unless wait_for(service, 'start', 20)
        raise EnginesException.new(error_hash('Time out in waiting for Service Dependancy Service startup' + service_name + ' to start ', service_name)) unless wait_for_startup(service, 120)
      end
    end
    started
  end

  def wait_for_dependacies_startup(container)
    if container.dependant_on.is_a?(Array)
      container.dependant_on.each do |service_name|
        service = engines_core.loadManagedService(service_name)
        wait_for_dependacy_startup(service)
      end
    end
  end

  def wait_for_dependacy_startup(service, timeout = 60)
    service.wait_for_startup(timeout)
  end
end