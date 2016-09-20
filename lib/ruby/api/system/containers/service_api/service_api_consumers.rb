module ServiceApiConsumers
  @@consumer_timeout=8
  
  def get_registered_consumer(params)
    p :retrieve_service_hash
    p params
    engines_core.get_registered_against_service(params)
  end
  
  def get_registered_against_service(params)
    engines_core.get_registered_against_service(params)
  end

  def add_consumer_to_service(c, service_hash)

   # cmd = 'docker_exec -u ' + c.cont_userid.to_s + ' ' + c.container_name.to_s  + ' /home/add_service.sh ' + SystemUtils.hash_variables_as_json_str(service_hash)
 
    cmd = ['/home/add_service.sh',   SystemUtils.hash_variables_as_json_str(service_hash[:variables]) ]
    SystemDebug.debug(SystemDebug.services,  :add_consumer_to_service, cmd.to_s)
    result = {}
    begin
      Timeout.timeout(@@consumer_timeout) do
        thr = Thread.new { result =  engines_core.exec_in_container({:container => c, :command_line => cmd, :log_error => true }) } #SystemUtils.execute_command(cmd) }
        thr.join
      end
    rescue Timeout::Error
      return log_error_mesg('Timeout on adding consumer to service ',cmd.to_s)
    end
    SystemDebug.debug(SystemDebug.services,  :add_consumer_to_service_res, result)
    return result if result.is_a?(EnginesError)
    return true if result[:result] == 0
    log_error_mesg('Failed add_consumer_to_service ' + c.to_s + ':' + service_hash[:variables].to_s + ':' + result.to_s,result)
  end

  def rm_consumer_from_service(c, service_hash)

#    cmd = 'docker_exec -u ' + c.cont_userid + ' ' + c.container_name + ' /home/rm_service.sh \'' + SystemUtils.hash_variables_as_json_str(service_hash) + '\''
    cmd =  ['/home/rm_service.sh' , SystemUtils.hash_variables_as_json_str(service_hash[:variables])]
    result = {}
    begin
      Timeout.timeout(@@consumer_timeout) do
        thr = Thread.new {result =  engines_core.exec_in_container({:container => c, :command_line => cmd, :log_error => true }) }
        thr.join
      end
    rescue Timeout::Error
      return log_error_mesg('Timeout on removing consumer from service',cmd)
    end
  return result if result.is_a?(EnginesError)
    return true  if result[:result] == 0
    log_error_mesg('Failed rm_consumer_from_service '  + c.to_s + ':' + service_hash[:variables].to_s + result.to_s, result )
  end
end