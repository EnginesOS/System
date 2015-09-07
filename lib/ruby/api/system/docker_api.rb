class DockerApi < ErrorsApi
  def create_container(container)
    clear_error
    commandargs = container_commandline_args(container)
    commandargs = 'docker run  -d ' + commandargs
    SystemUtils.debug_output('create cont', commandargs)
    execute_docker_cmd(commandargs, container)
  rescue StandardError => e
    container.last_error = ('Failed To Create ')
    log_exception(e)
  end

  def start_container(container)
    clear_error
    commandargs = 'docker start ' + container.container_name
    execute_docker_cmd(commandargs, container)
  rescue StandardError => e
    log_exception(e)
  end

  def stop_container(container)
    clear_error
    commandargs = 'docker stop ' + container.container_name
    execute_docker_cmd(commandargs, container)
  rescue StandardError => e
    log_exception(e)
  end

  def pause_container(container)
    clear_error
    commandargs = 'docker pause ' + container.container_name
    execute_docker_cmd(commandargs, container)
  rescue StandardError => e
    log_exception(e)
  end

  def pull_image(image_name)
    cmd = 'docker pull ' + image_name
    SystemUtils.debug_output('Pull Image', cmd)
    result = SystemUtils.execute_command(cmd)
    @last_error = result[:stdout]
    if result[:result] != 0
      return true if result[:stdout].include?('Status: Image is up to date for ' + image_name) == true
      @last_error += ':' + result[:stderr].to_s
      return false
    end
    return true if result[:stdout].include?('Status: Image is up to date for ' + image_name) == true
    @last_error += ':' + result[:stderr].to_s
    return true
  rescue StandardError => e
    log_exception(e)
  end

  def image_exist?(imagename)
    image_name = imagename.gsub(/:.*$/, '')
    cmd = 'docker images -q ' + image_name
    result = SystemUtils.execute_command(cmd)
    @last_error = result[:stderr].to_s
    return false if result[:result] != 0
    return true if result[:stdout].length > 4
    return false # Otherwise returnsresult[:stdout] 
  rescue StandardError => e
    log_exception(e)
  end

  def unpause_container(container)
    clear_error
    commandargs = 'docker unpause ' + container.container_name
    execute_docker_cmd(commandargs, container)
  rescue StandardError => e
    log_exception(e)
  end

  def ps_container(container)
    cmdline = 'docker top ' + container.container_name + ' axl'
    result = SystemUtils.execute_command(cmdline)
    return result[:stdout] if result[:result] == 0
    return false
  rescue StandardError => e
    log_exception(e)
  end

  def execute_docker_cmd(cmdline, container)
    clear_error
    if cmdline.include?('docker exec')
      docker_exec = 'docker exec -u ' + container.cont_userid + ' '
      cmdline.gsub!(/docker exec/, docker_exec)
    end
    result = SystemUtils.execute_command(cmdline)
    container.last_result = result[:stdout]
    if container.last_result.start_with?('[') && !container.last_result.end_with?(']')  # || container.last_result.end_with?(']') )
      container.last_result += ']'
    end
    container.last_error = result[:stderr]
    if result[:result] == 0
      container.last_error = result[:result].to_s + ':' + result[:stderr].to_s
      return true
    else
      log_error_mesg('execute_docker_cmd ' + cmdline + ' on ' + container.container_name, result)
      return false
    end
  rescue StandardError => e
    log_exception(e)
  end

  def signal_container_process(pid, signal, container)
    clear_error
    commandargs = 'docker exec ' + container.container_name + ' kill -' + signal + ' ' + pid.to_s
    execute_docker_cmd(commandargs, container)
  rescue StandardError => e
    log_exception(e)
  end

  def logs_container(container)
    clear_error
    cmdline = 'docker logs ' + container.container_name
    result = SystemUtils.execute_command(cmdline)
    return result[:stdout] if result[:result] == 0
    return false
  rescue StandardError => e
    log_exception(e)
    return 'error'
  end

  def inspect_container(container)
    clear_error
    commandargs = ' docker inspect ' + container.container_name
    execute_docker_cmd(commandargs, container)
  rescue StandardError => e
    log_exception(e)
  end

  def destroy_container(container)
    clear_error
    commandargs = 'docker  rm ' + container.container_name
    unless execute_docker_cmd(commandargs, container)
      log_error_mesg(container.last_error, container)
      return false if image_exist?(container.image)
    end
    clean_up_dangling_images
    return true
  rescue StandardError => e
    container.last_error = 'Failed To Destroy ' + e.to_s
    log_exception(e)
  end

  def delete_image(container)
    clear_error
    commandargs = 'docker rmi -f ' + container.image
    ret_val = execute_docker_cmd(commandargs, container)
    clean_up_dangling_images if ret_val == true
    return ret_val
  rescue StandardError => e
    container.last_error = ('Failed To Delete ' + e.to_s)
    log_exception(e)
  end

  def docker_exec(container, command, args)
    run_args = 'docker exec ' + container.container_name + ' ' + command + ' ' + args
    execute_docker_cmd(run_args, container)
  end

  def get_environment_options(container)
    e_option = ''
    if container.environments && container.environments.nil? == false
      container.environments.each do |environment|
        if environment.nil? == false \
        && environment.name.nil? == false \
        && environment.value.nil? == false \
        && environment.has_changed == true \
        && environment.build_time_only == false
          environment.value.gsub!(/ /,'\\ ')
          e_option += ' -e \'' + environment.name + '=' + environment.value + '\''
        end
      end
    end
    return e_option
  rescue StandardError => e
    log_exception(e)
    return e.to_s
  end

  def get_port_options(container)
    eportoption = ''
    if container.eports
      container.eports.each do |eport|
        unless eport.nil?
          if eport.external.nil? == false && eport.external > 0
            eportoption += ' -p '
            eportoption += eport.external.to_s + ':'
            eportoption += eport.port.to_s
            eport.proto_type = 'tcp' if eport.proto_type.nil?
            eportoption += '/' + eport.proto_type + ' '
          end
        end
      end
    end
    return eportoption
  rescue StandardError => e
    log_exception(e)
    return e.to_s
  end

  def container_commandline_args(container)
    clear_error
    environment_options = get_environment_options(container)
    port_options = get_port_options(container)
    volume_option = get_volume_option(container)
    return false if volume_option == false || environment_options == false || port_options == false
    start_cmd = ' '
    start_cmd = ' /bin/bash /home/init.sh' unless container.conf_self_start
    commandargs = '-h ' + container.hostname + \
    environment_options + \
    ' --memory=' + container.memory.to_s + 'm ' + \
    volume_option + ' ' + \
    port_options + \
    ' --cidfile ' + SystemConfig.CidDir + '/' + container.container_name + '.cid ' + \
    '--name ' + container.container_name + \
    '  -t ' + container.image + ' ' + \
    start_cmd
    return commandargs
  rescue StandardError => e
    log_exception(e)
    return e.to_s
  end

  def get_volume_option(container)
    clear_error
    volume_option = SystemConfig.timeZone_fileMapping # latter this will be customised
    volume_option += ' -v ' + container_state_dir(container) + '/run:/engines/var/run:rw '
    incontainer_logdir = get_container_logdir(container)
    volume_option += ' -v ' + container_log_dir(container) + ':/' + incontainer_logdir + ':rw '
    volume_option += ' -v ' + container_log_dir(container) + '/vlog:/var/log/:rw' if incontainer_logdir != '/var/log' && incontainer_logdir != '/var/log/'
    volume_option += ' -v ' + service_sshkey_local_dir(container) + ':' + service_sshkey_container_dir(container) + ':rw' if container.is_service?
    volume_option += ' -v ' + SystemConfig.EnginesInternalCA + ':/usr/local/share/ca-certificates/engines_internal_ca.crt:ro ' unless container.no_ca_map
    if container.volumes.is_a?(Hash)
      container.volumes.each_value do |volume|
        unless volume.nil?
          unless volume.localpath.nil?
            volume_option = volume_option.to_s + ' -v ' + volume.localpath.to_s + ':/' + volume.remotepath.to_s + ':' + volume.mapping_permissions.to_s
          end
        end
      end
    else
      p :panic_vols_not_a_hash_but
      p container.volumes.class.name
    end
    return volume_option
  rescue StandardError => e
    log_exception(e)
  end

  def service_sshkey_local_dir(container)
    '/opt/engines/ssh/keys/services/' + container.container_name
  end

  def service_sshkey_container_dir(container)
    '/home/.ssh/'
  end

  def get_container_logdir(container)
    clear_error
    return '/var/log' if container.framework.nil? || container.framework.length == 0
    container_logdetails_file_name = false
    framework_logdetails_file_name = SystemConfig.DeploymentTemplates + '/' + container.framework + '/home/LOG_DIR'
    SystemUtils.debug_output('Frame logs details', framework_logdetails_file_name)
    if File.exist?(framework_logdetails_file_name)
      container_logdetails_file_name = framework_logdetails_file_name
    else
      container_logdetails_file_name = SystemConfig.DeploymentTemplates + '/global/home/LOG_DIR'
    end
    SystemUtils.debug_output('Container log details', container_logdetails_file_name)
    begin
      container_logdetails = File.read(container_logdetails_file_name)
    rescue
      container_logdetails = '/var/log'
    end
    return container_logdetails
  rescue StandardError => e
    log_exception(e)
  end

  def clean_up_dangling_images
    cmd = 'docker rmi $( docker images -f \'dangling=true\' -q) &'
    Thread.new { SystemUtils.execute_command(cmd) }
    return true # often warning not error
  end

  protected

  def container_state_dir(container)
    ContainerStateFiles.container_state_dir(container)
  end

  def container_log_dir(container)
    SystemConfig.SystemLogRoot + '/' + container.ctype + 's/' + container.container_name
  end
end
