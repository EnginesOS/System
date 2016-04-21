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

   # cmd = 'docker exec -u ' + c.cont_userid.to_s + ' ' + c.container_name.to_s  + ' /home/add_service.sh ' + SystemUtils.hash_variables_as_json_str(service_hash)
 
    cmd = 'docker exec  ' + c.container_name.to_s  + ' /home/add_service.sh \'' + SystemUtils.hash_variables_as_json_str(service_hash[:variables]) +'\''
    SystemDebug.debug(SystemDebug.services,  :add_consumer_to_service, cmd)
    result = {}
    begin
      Timeout.timeout(@@consumer_timeout) do
        thr = Thread.new { result = SystemUtils.execute_command(cmd) }
        thr.join
      end
    rescue Timeout::Error
      return log_error_mesg('Timeout on adding consumer to service ',cmd)
    end
    SystemDebug.debug(SystemDebug.services,  :add_consumer_to_service_res, result)
    return true if result[:result] == 0
    log_error_mesg('Failed add_consumer_to_service',result)
  end

  def rm_consumer_from_service(c, service_hash)

#    cmd = 'docker exec -u ' + c.cont_userid + ' ' + c.container_name + ' /home/rm_service.sh \'' + SystemUtils.hash_variables_as_json_str(service_hash) + '\''
    cmd = 'docker exec  ' + c.container_name + ' /home/rm_service.sh \'' + SystemUtils.hash_variables_as_json_str(service_hash[:variables])  +'\''
    result = {}
    begin
      Timeout.timeout(@@consumer_timeout) do
        thr = Thread.new {result = SystemUtils.execute_command(cmd) }
        thr.join
      end
    rescue Timeout::Error
      return log_error_mesg('Timeout on removing consumer from service',cmd)
    end
    return true  if result[:result] == 0
    log_error_mesg('Failed rm_consumer_from_service', result)
  end
end