module ServiceApiConsumers
  @@consumer_timeout=8
  def get_registered_consumer(params)
    engines_core.get_registered_against_service(params)
  end

  def get_registered_against_service(params)
    engines_core.get_registered_against_service(params)
  end

  def add_consumer_to_service(c, service_hash)
    cmd = ['/home/add_service.sh']
    SystemDebug.debug(SystemDebug.services,  :add_consumer_to_service, cmd.to_s)
    result =  engines_core.exec_in_container({:container => c, :command_line => cmd, :log_error => true , :timeout => @@consumer_timeout, :data => service_hash.to_json})
    return true if result[:result] == 0
    raise EnginesException.new(error_hash('Failed add_consumer_to_service ', result))
  end

  def rm_consumer_from_service(c, service_hash)
    cmd = ['/home/rm_service.sh']
    result =  engines_core.exec_in_container({:container => c, :command_line => cmd, :log_error => true , :timeout => @@consumer_timeout, :data => service_hash.to_json } )
    return true if result[:result] == 0
    raise EnginesException.new(error_hash('Failed add_consumer_to_service ', result))
  end
end