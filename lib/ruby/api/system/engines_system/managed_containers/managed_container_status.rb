module ManagedContainerStatus
  def get_engines_states
    result = {}
    engines = getManagedEngines #list_managed_engines
    engines.each do |engine|
      begin
        result[engine.container_name] = engine.read_state
      rescue #skip services down
      end
    end
    result
  end

  def get_engines_status
    result = {}
    engines =  getManagedEngines # list_managed_services
    engines.each do |engine|
      begin
        result[engine.container_name] = engine.status
      rescue #skip services down
      end
    end
    result
  end

  def get_services_status
    result = {}
    services =  getManagedServices # list_managed_services
    services.each do |service|
      begin
        result[service.container_name] = service.status
      rescue #skip services down
      end
    end
    return result
  end

  def get_services_states
    services =  getManagedServices # list_managed_services
    result = {}
    services.each do |service|
      begin
        result[service.container_name] = service.read_state
      rescue DockerException
        next
      end
    end
    result
  end
end