class ContainerApi < ErrorsApi
  def initialize(docker_api, system_api, engines_core)
    @docker_api = docker_api
    @system_api = system_api
    @engines_core = engines_core
  end

  def web_sites_for(container)
    @engines_core.web_sites_for(container)
  end

  def get_container_memory_stats(container)
    test_system_api_result(@system_api.get_container_memory_stats(container))
  end

  def get_container_network_metrics(container)
    test_system_api_result(@system_api.get_container_network_metrics(container.container_name))
  end

  def unpause_container(container)
    clear_error
    test_docker_api_result(@docker_api.unpause_container(container))
  end

  def pause_container(container)
    clear_error
    test_docker_api_result(@docker_api.pause_container(container))
  end

  def inspect_container(container)
    clear_error
    test_docker_api_result(@docker_api.inspect_container(container))
  end

  def stop_container(container)
    clear_error
    test_docker_api_result(@docker_api.stop_container(container))
  end

  def ps_container(container)
    test_docker_api_result(@docker_api.ps_container(container))
  end

  def logs_container(container)
    clear_error
    test_docker_api_result(@docker_api.logs_container(container))
  end

  def start_container(container)
    clear_error
    start_dependancies(container) if container.dependant_on.is_a?(Array)
    test_docker_api_result(@docker_api.start_container(container))
  end

  def save_container(container)
    test_system_api_result(@system_api.save_container(container))
  end

  def test_docker_api_result(result)
    @last_error = @docker_api.last_error if result.nil? || result == false
    return result
  end

  def delete_image(container)
    clear_error
    return  test_system_api_result(@system_api.delete_container_configs(container)) if test_docker_api_result(@docker_api.delete_image(container))
    # only delete if del all otherwise backup
    # NO Image well delete the rest
    test_system_api_result(@system_api.delete_container_configs(container)) if !test_docker_api_result(@docker_api.image_exist?(container.image))
    p 'delete_imatge'
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def destroy_container(container)
    clear_error
    ret_val = true
    ret_val = test_docker_api_result(@docker_api.destroy_container(container)) if container.has_container?
    ret_val = test_docker_api_result(@system_api.destroy_container(container)) if ret_val
    return ret_val
  rescue StandardError => e
    container.last_error = 'Failed To Destroy ' + e.to_s
    log_exception(e)
  end

  def is_startup_complete(container)
    clear_error
    return test_system_api_result(@system_api.is_startup_complete(container))
  rescue StandardError => e
    log_exception(e)
  end

  def create_container(container)
    clear_error
    return log_error_mesg('Failed To create container exists by the same name', container) if container.ctype != 'system_service' && container.has_container?
    test_system_api_result(@system_api.clear_cid_file(container))
    test_system_api_result(@system_api.clear_container_var_run(container))
    start_dependancies(container) if container.dependant_on.is_a?(Array)
    container.pull_image if container.ctype != 'container'
    return test_system_api_result(@system_api.create_container(container)) if test_docker_api_result(@docker_api.create_container(container))
    return false
  rescue StandardError => e
    container.last_error = ('Failed To Create ' + e.to_s)
    log_exception(e)
  end

  def save_blueprint(blueprint, container)
    test_system_api_result(@system_api.save_blueprint(blueprint, container))
  end

  def load_blueprint(container)
    test_system_api_result(@system_api.load_blueprint(container))
  end

  def attach_service(service_hash)
    @engines_core.attach_service(service_hash)
  end

  # Called by Managed Containers
  def register_non_persistant_services(engine)
    check_sm_result(@engines_core.service_manager.register_non_persistant_services(engine))
  end

  # Called by Managed Containers
  def deregister_non_persistant_services(engine)
    check_sm_result(@engines_core.service_manager.deregister_non_persistant_services(engine))
  end

  def image_exist?(image)
    @engines_core.image_exist?(image)
  end

  private

  def check_sm_result(result)
    @last_error += @engines_core.service_manager.last_error.to_s if result.nil? ||result.is_a?(FalseClass)
    return result
  end

  def has_service_started?(service_name)
    completed_flag_file = SystemConfig.RunDir + '/services/' + service_name + '/run/flags/startup_complete'
    File.exist?(completed_flag_file)
  end

  def start_dependancies(container)
    container.dependant_on.each do |service_name|
      service = @engines_core.loadManagedService(service_name)
      return log_error_mesg('Failed to load ', service_name) if service == false
      if !service.is_running?
        if service.has_container?
          if service.is_active?
            return log_error_mesg('Failed to unpause ', service_name) if !service.unpause_container
            return log_error_mesg('Failed to start ', service_name) if !service.start_container
          end
          return log_error_mesg('Failed to create ', service_name) if !service.create_container
        end
      end
      retries = 0
      while !has_service_started?(service_name)
        sleep 10
        retries += 1
        return log_error_mesg('Time out in waiting for Service Dependancy ' + service_name + ' to start ', service_name) if retries > 3
      end
    end
    return true
  end

  def test_system_api_result(result)
    @last_error = @system_api.last_error.to_s if result.nil? || result.is_a?(FalseClass)
    return result
  end

  def check_system_api_result(result)
    @last_error = @system_api.last_error.to_s[0, 128] if result.nil? || result.is_a?(FalseClass)
    return result
  end
end
