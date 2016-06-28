#def execute_docker_cmd(cmdline, container)
#  @docker_comms.docker_exec(container, cmdline, false)
#  rescue StandardError => e
#    log_exception(e)
##  clear_error
##  if cmdline.include?('docker exec')
##    docker_exec = 'docker exec -u ' + container.cont_userid + ' '
##    cmdline.gsub!(/docker exec/, docker_exec)
##  end
##  SystemDebug.debug(SystemDebug.docker, :docker_exec, cmdline)
##  run_docker_cmd(cmdline, container)
#end
def old_docker_cmd_w(cmdline, container, log_error = true)
    result = SystemUtils.execute_command(cmdline)
    container.last_result = result[:stdout]
  
    container.last_error = result[:stderr]
    if result[:result] == 0
      container.last_error = result[:result].to_s + ':' + result[:stderr].to_s
  
      return result[:sdout]
    else
      container.last_error = result[:result].to_s + ':' + result[:stderr].to_s
     return log_error_mesg('execute_docker_cmd ' + cmdline + ' on ' + container.container_name, result)  if log_error
  
    end
  rescue StandardError => e
    log_exception(e)
end
#def run_docker_cmd(cmdline, container, log_error = true)
#  @docker_comms.docker_exec(container, cmdline, log_error)
##  result = SystemUtils.execute_command(cmdline)
##  container.last_result = result[:stdout]
##  container.last_error = result[:stderr]
##  if result[:result] == 0
##    container.last_error = result[:result].to_s + ':' + result[:stderr].to_s
##
##    return true
##  else
##    container.last_error = result[:result].to_s + ':' + result[:stderr].to_s
##    log_error_mesg('execute_docker_cmd ' + cmdline + ' on ' + container.container_name, result)  if log_error
##    return false
##  end
#rescue StandardError => e
#  log_exception(e)
#end

#def docker_cmd_w(cmdline, container, log_error = true)
#  @docker_comms.docker_exec(container, cmdline, log_error)
##  result = SystemUtils.execute_command(cmdline)
##  container.last_result = result[:stdout]
##
##  container.last_error = result[:stderr]
##  if result[:result] == 0
##    container.last_error = result[:result].to_s + ':' + result[:stderr].to_s
##
##    return result[:sdout]
##  else
##    container.last_error = result[:result].to_s + ':' + result[:stderr].to_s
##   return log_error_mesg('execute_docker_cmd ' + cmdline + ' on ' + container.container_name, result)  if log_error
##
##  end
#rescue StandardError => e
#  log_exception(e)
#end
