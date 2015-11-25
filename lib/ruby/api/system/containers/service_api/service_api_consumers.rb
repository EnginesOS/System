module ServiceApiConsumers
  def load_and_attach_persistant_services(container)
    dirname = container_services_dir(container) + '/pre/'
    engines_core.load_and_attach_services(dirname, container)
  end

  def load_and_attach_shared_services(container)
    dirname = container_services_dir(container) + '/shared/'
    engines_core.load_and_attach_services(dirname, container)
  end

  def load_and_attach_nonpersistant_services(container)
    dirname = container_services_dir(container) + '/post/'
    engines_core.load_and_attach_services(dirname, container)
  end

  def get_registered_against_service(params)
    engines_core.get_registered_against_service(params)
  end

  def add_consumer_to_service(service_hash)

    cmd = 'docker exec -u ' + @cont_userid.to_s + ' ' + @container_name.to_s  + ' /home/add_service.sh ' + SystemUtils.service_hash_variables_as_str(service_hash)
    result = {}
    begin
      Timeout.timeout(@@script_timeout) do
        thr = Thread.new { result = SystemUtils.execute_command(cmd) }
        thr.join
      end
    rescue Timeout::Error
      log_error_mesg('Timeout on adding consumer to service ',cmd)
      return {}
    end
    return true if result[:result] == 0
    log_error_mesg('Failed add_consumer_to_service',result)
  end

  def rm_consumer_from_service(service_hash)

    cmd = 'docker exec -u ' + @cont_userid + ' ' + @container_name + ' /home/rm_service.sh \'' + SystemUtils.service_hash_variables_as_str(service_hash) + '\''
    result = {}
    begin
      Timeout.timeout(@@script_timeout) do
        thr = Thread.new {result = SystemUtils.execute_command(cmd) }
        thr.join
      end
    rescue Timeout::Error
      log_error_mesg('Timeout on removing consumer from service',cmd)
      return {}
    end
    return true  if result[:result] == 0
    log_error_mesg('Failed rm_consumer_from_service', result)
  end
end