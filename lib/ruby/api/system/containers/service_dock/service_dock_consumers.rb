module ServiceDockConsumers
  @@consumer_timeout=8
  def get_registered_consumer(params)
    core.registered_with_service(params)
  end

  def registered_with_service(params)
    core.registered_with_service(params)
  end

  def add_consumer_to_service(c, service_hash)
    result = dock_face.docker_exec(
    {:container => c,
      :command_line =>  ['/home/engines/scripts/services/add_service.sh'],
      :log_error => true,
      :timeout => @@consumer_timeout,
      service_variables: service_hash
      })
    raise EnginesException.new(error_hash('Failed add_consumer_to_service ' + result.to_s + ' 4 ' + service_hash.to_s , result)) unless result[:result] == 0
  end

  def update_consumer_on_service(c, service_hash)
    unless c.persistent == true && c.is_soft_service? != true
      rm_consumer_from_service(c, service_hash)
      add_consumer_to_service(c, service_hash)
    else
      result = dock_face.docker_exec(
      {container: c,
        command_line: ['/home/engines/scripts/services/update_service.sh'],
        log_error: true,
        timeout: @@consumer_timeout,
      service_variables: service_hash
      })
      raise EnginesException.new(error_hash('Failed update_consumer_on_service ' + result.to_s, result)) unless result[:result] == 0
    end
  end

  def rm_consumer_from_service(c, service_hash)
    result = dock_face.docker_exec(
    {container: c,
      command_line: ['/home/engines/scripts/services/rm_service.sh'],
      log_error: true,
      timeout: @@consumer_timeout,
      service_variables: service_hash
      })
    raise EnginesException.new(error_hash('Failed rm_consumer_from_service ', result)) unless result[:result] == 0
  end
end
