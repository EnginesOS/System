def execute_docker_cmd(cmdline, container)
  clear_error
  if cmdline.include?('docker exec')
    docker_exec = 'docker exec -u ' + container.cont_userid + ' '
    cmdline.gsub!(/docker exec/, docker_exec)
  end
  p :docker_exec
  p cmdline
  run_docker_cmd(cmdline, container)
end

def run_docker_cmd(cmdline, container, log_error = true)

  result = SystemUtils.execute_command(cmdline)
  container.last_result = result[:stdout]
  #    if container.last_result.start_with?('[') && !container.last_result.end_with?(']')  # || container.last_result.end_with?(']') )
  #      container.last_result += ']'
  #    end
  container.last_error = result[:stderr]
  if result[:result] == 0
    container.last_error = result[:result].to_s + ':' + result[:stderr].to_s

    return true
  else
    container.last_error = result[:result].to_s + ':' + result[:stderr].to_s
    log_error_mesg('execute_docker_cmd ' + cmdline + ' on ' + container.container_name, result)  if log_error
    return false
  end
rescue StandardError => e
  log_exception(e)
end
