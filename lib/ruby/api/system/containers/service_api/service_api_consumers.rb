module ServiceApiConsumers
  @@consumer_timeout=8
  
  def load_and_attach_persistent_services(container)
    dirname = container_services_dir(container) + '/pre/'
    engines_core.load_and_attach_services(dirname, container)
  end

  def load_and_attach_shared_services(container)
    dirname = container_services_dir(container) + '/shared/'
    engines_core.load_and_attach_services(dirname, container)
  end

  def load_and_attach_nonpersistent_services(container)
    dirname = container_services_dir(container) + '/post/'
    engines_core.load_and_attach_services(dirname, container)
  end

  def get_registered_against_service(params)
    engines_core.get_registered_against_service(params)
  end

  def add_consumer_to_service(c, service_hash)

   # cmd = 'docker exec -u ' + c.cont_userid.to_s + ' ' + c.container_name.to_s  + ' /home/add_service.sh ' + SystemUtils.service_hash_variables_as_str(service_hash)
 
    cmd = 'docker exec  ' + c.container_name.to_s  + ' /home/add_service.sh \'' + SystemUtils.service_hash_variables_as_str(service_hash) +'\''
    SystemUtils.debug_output(  :add_consumer_to_service, cmd)
    result = {}
    begin
      Timeout.timeout(@@consumer_timeout) do
        thr = Thread.new { result = SystemUtils.execute_command(cmd) }
        thr.join
      end
    rescue Timeout::Error
      return log_error_mesg('Timeout on adding consumer to service ',cmd)
    end
    SystemUtils.debug_output(  :add_consumer_to_service_res, result)
    return true if result[:result] == 0
    log_error_mesg('Failed add_consumer_to_service',result)
  end

  def rm_consumer_from_service(c, service_hash)

#    cmd = 'docker exec -u ' + c.cont_userid + ' ' + c.container_name + ' /home/rm_service.sh \'' + SystemUtils.service_hash_variables_as_str(service_hash) + '\''
    cmd = 'docker exec  ' + c.container_name + ' /home/rm_service.sh \'' + SystemUtils.service_hash_variables_as_str(service_hash)  +'\''
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