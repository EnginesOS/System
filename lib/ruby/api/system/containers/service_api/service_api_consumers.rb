module ServiceApiConsumers
  @@consumer_timeout=8
  def get_registered_consumer(params)
    engines_core.registered_with_service(params)
  end

  def registered_with_service(params)
    engines_core.registered_with_service(params)
  end

  def add_consumer_to_service(c, service_hash)
    cmd = ['/home/add_service.sh']
    SystemDebug.debug(SystemDebug.services, :add_consumer_to_service, cmd.to_s)
     engines_core.exec_in_container(
    {:container => c,
      :command_line => cmd,
      :log_error => true,
      :timeout => @@consumer_timeout,
      :data => service_hash.to_json})
    # STDERR.puts('ADD SERVICE' + result.to_s)
    raise EnginesException.new(error_hash('Failed add_consumer_to_service ' + result.to_s, result)) unless result[:result] == 0
  end

  def update_consumer_on_service(c, service_hash)
    #  raise EnginesException.new(error_hash('cannot not update consumer on non persistent service ' + service_hash.to_s, result)) unless @persistent == true
    unless c.persistent == true && c.soft_service != true
      rm_consumer_from_service(c, service_hash)
      add_consumer_to_service(c, service_hash)
    else
      cmd = ['/home/update_service.sh']
      SystemDebug.debug(SystemDebug.services, :update_consumer_on_service, cmd.to_s)
      engines_core.exec_in_container(
      {container: c,
        command_line: cmd,
        log_error: true,
        timeout: @@consumer_timeout,
        data: service_hash.to_json})
      #   STDERR.puts('UPDATE SERVICE' + result.to_s)
      raise EnginesException.new(error_hash('Failed update_consumer_on_service ' + result.to_s, result)) unless result[:result] == 0
    end
  end

  def rm_consumer_from_service(c, service_hash)
    cmd = ['/home/rm_service.sh']
    engines_core.exec_in_container(
    {container: c,
      command_line: cmd,
      log_error: true,
      timeout: @@consumer_timeout,
      data: service_hash.to_json })
    #  STDERR.puts('RM SERVICE ' + result.to_s)
    raise EnginesException.new(error_hash('Failed add_consumer_to_service ', result)) unless result[:result] == 0
  end
end