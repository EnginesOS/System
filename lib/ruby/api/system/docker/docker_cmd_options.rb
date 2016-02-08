module DockerCmdOptions
  def self.container_commandline_args(container)
    environment_options = get_environment_options(container)
    port_options = get_port_options(container)
    volume_option = get_volume_option(container)
    arguments = get_container_arguments(container)

    return false if volume_option == false || environment_options == false || port_options == false
    start_cmd = ' '
    start_cmd = ' /bin/bash /home/start.bash' unless container.conf_self_start
    commandargs =  get_networking_args(container) \
    + environment_options + \
    ' --memory=' + container.memory.to_s + 'm ' + \
    volume_option + ' ' + \
    port_options + \
    ' --cidfile ' + SystemConfig.CidDir + '/' + container.container_name + '.cid ' + \
    '--name ' + container.container_name + \
    '  -t ' + container.image + ' ' + \
    start_cmd +\
    arguments.to_s

    return commandargs
  rescue StandardError => e
    SystemUtils.log_exception(e)
    return e.to_s
  end

  def self.get_networking_args(container)
    return '-h ' + container.hostname +  ' --dns-search=' + SystemConfig.internal_domain + ' ' if container.on_host_net? == false
    return ' --net=host '
  end

  private

  def self.get_container_arguments(container)
    return nil unless container.arguments.present?
    return nil if container.arguments.nil?
    return nil unless container.arguments.is_a?(Array)
    retval = ''
    arguments.each  do |arg|
      retval = retval + ' ' + arg.to_s
    end

    return retval

  end

  def self.service_sshkey_local_dir(container)
    '/opt/engines/etc/ssh/keys/services/' + container.container_name
  end

  def self.service_sshkey_container_dir(container)
    '/home/.ssh/'
  end

  def self.container_state_dir(container)
    ContainerStateFiles.container_state_dir(container)
  end

  def self.container_log_dir(container)
    SystemConfig.SystemLogRoot + '/' + container.ctype + 's/' + container.container_name
  end

  def self.get_environment_options(container)
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
    SystemUtils.log_exception(e)
    return e.to_s
  end

  def self.get_port_options(container)
    return  ' '  if container.on_host_net? == true
    eportoption = ''
    if container.mapped_ports
      container.mapped_ports.each do |eport|
        unless eport.nil?
          if eport.external.nil? == false && eport.external > 0
            eportoption += ' -p '
            eportoption += eport.external.to_s + ':'
            eportoption += eport.port.to_s
            if eport.proto_type.nil?
              eport.proto_type = 'tcp'
            elsif eport.proto_type.downcase.include?('and')
              eport.proto_type = 'both'
            else
              eportoption += '/' + eport.proto_type + ' '
            end
          end
        end
      end
    end
    return eportoption
  rescue StandardError => e
    SystemUtils.log_exception(e)
    return e.to_s
  end

  def self.get_container_logdir(container)
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
    SystemUtils.log_exception(e)
  end

  def self.get_volume_option(container)
    volume_option = SystemConfig.timeZone_fileMapping # latter this will be customised
    volume_option += ' -v ' + container_state_dir(container) + '/run:/engines/var/run:rw '
    incontainer_logdir = get_container_logdir(container)
    volume_option += ' -v ' + container_log_dir(container) + ':/' + incontainer_logdir + ':rw '
    volume_option += ' -v ' + container_log_dir(container) + '/vlog:/var/log/:rw' if incontainer_logdir != '/var/log' && incontainer_logdir != '/var/log/'
    volume_option += ' -v ' + service_sshkey_local_dir(container) + ':' + service_sshkey_container_dir(container) + ':rw' if container.is_service?
    volume_option += ' -v ' + SystemConfig.EnginesInternalCA + ':/usr/local/share/ca-certificates/engines_internal_ca.crt:ro ' unless container.no_ca_map
    if container.large_temp
      #FIXME use container for tmp to enforce a 1GB limit ?
      temp_dir_name =   container.ctype + '/' + container.container_name
      volume_option += ' -v ' + SystemConfig.EnginesTemp + '/' + temp_dir_name + ':/tmp:rw '
      SystemUtils.execute_command('/opt/engines/scripts/make_big_temp.sh ' + temp_dir_name)
      p        volume_option
    end
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
    SystemUtils.log_exception(e)
  end

end