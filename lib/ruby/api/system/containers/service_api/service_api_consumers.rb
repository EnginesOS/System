module ServiceApiConsumers
  @@consumer_timeout=8
  def get_registered_consumer(params)
    core.registered_with_service(params)
  end

  def registered_with_service(params)
    core.registered_with_service(params)
  end

  def add_consumer_to_service(c, service_hash)
    # cmd = ['/home/engines/scripts/services/add_service.sh']
   # SystemDebug.debug(SystemDebug.services, :add_consumer_to_service, service_hash.to_s)
    result = core.exec_in_container(
    {:container => c,
      :command_line =>  ['/home/engines/scripts/services/add_service.sh'],
      :log_error => true,
      :timeout => @@consumer_timeout,
      service_variables: service_hash
   #   data: service_hash.to_json
      })
    # STDERR.puts('ADD SERVICE' + result.to_s)
    raise EnginesException.new(error_hash('Failed add_consumer_to_service ' + result.to_s + ' 4 ' + service_hash.to_s , result)) unless result[:result] == 0
  end

  def update_consumer_on_service(c, service_hash)
    #  raise EnginesException.new(error_hash('cannot not update consumer on non persistent service ' + service_hash.to_s, result)) unless @persistent == true
    unless c.persistent == true && c.is_soft_service? != true
      rm_consumer_from_service(c, service_hash)
      add_consumer_to_service(c, service_hash)
    else
      #  cmd = ['/home/engines/scripts/services/update_service.sh']
  #    SystemDebug.debug(SystemDebug.services, :update_consumer_on_service, service_hash.to_s)
      result = core.exec_in_container(
      {container: c,
        command_line: ['/home/engines/scripts/services/update_service.sh'],
        log_error: true,
        timeout: @@consumer_timeout,
      service_variables: service_hash
   #   data: service_hash.to_json
      })
      #   STDERR.puts('UPDATE SERVICE' + result.to_s)
      raise EnginesException.new(error_hash('Failed update_consumer_on_service ' + result.to_s, result)) unless result[:result] == 0
    end
  end

  def rm_consumer_from_service(c, service_hash)
    # cmd = ['/home/engines/scripts/services/rm_service.sh']
    result = core.exec_in_container(
    {container: c,
      command_line: ['/home/engines/scripts/services/rm_service.sh'],
      log_error: true,
      timeout: @@consumer_timeout,
      service_variables: service_hash
   #   data: service_hash.to_json
      })
   #   STDERR.puts('RM SERVICE:' + service_hash.to_s + ':Res:' + result.to_s)
    raise EnginesException.new(error_hash('Failed rm_consumer_from_service ', result)) unless result[:result] == 0
  end
end
