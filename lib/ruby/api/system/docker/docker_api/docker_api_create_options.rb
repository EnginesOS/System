module DockerApiCreateOptions
  def initialize
    @top_level = nil
  end
  require '/opt/engines/lib/ruby/api/system/container_state_files.rb'

  def create_options(container)
    @top_level = build_top_level(container)
  end

  def get_protocol_str(port)
    if port[:proto_type].nil?
      'tcp'
    else
      port[:proto_type]
    end
  end

  def exposed_ports(container)
    eports = {}
    unless container.mapped_ports.nil?
      container.mapped_ports.each_value do |port|
        port = symbolize_keys(port)
        if port[:port].is_a?(String) && port[:port].include?('-')
          expose_port_range(eports, port)
        else
          add_exposed_port(eports, port)
        end
      end
    end
    eports
  end

  def volumes_mounts(container)
    mounts = []
    if container.volumes.nil?
      system_mounts(container)
    else
      container.volumes.each_value do |volume|
        mounts.push(mount_string(volume))
      end
      sm = system_mounts(container)
      mounts.concat(sm) unless sm.nil?
      rm = registry_mounts(container)
      mounts.concat(sm) unless sm.nil?
      mounts
    end
  end

  def mount_string(volume)
    volume = symbolize_keys(volume)
    perms = 'ro'
    if volume[:permissions] == 'rw'
      perms = 'rw'
    else
      perms = 'ro'
    end
    volume[:localpath] + ':' + volume[:remotepath] + ':' + perms
  end

  def get_dns_search
    search = []
    search.push(SystemConfig.internal_domain)
    search
  end
  require '/opt/engines/lib/ruby/api/system/system_status.rb'

  def get_dns_servers
    servers = []
    servers.push( SystemStatus.get_docker_ip)
    servers
  end

  def container_memory(container)
    container.memory.to_i * 1024 * 1024
  end

  def container_volumes(container)
    unless container.volumes_from.nil?
      container.volumes_from
    else
      []
    end
  end

  def container_capabilities(container)
    unless container.capabilities.nil?
      add_capabilities(container.capabilities)
    else
      []
    end
  end

  def container_get_dns_servers(container)
    get_dns_servers
  end

  def container_dns_search(container)
    get_dns_search
  end

  def container_network_mode(container)
    if container.on_host_net? == false
      'bridge'
    else
      'host'
    end
  end

  def host_config_options(container)
    {
      'Binds' => volumes_mounts(container),
      'Memory' => container_memory(container),
      'MemorySwap' => container_memory(container) * 2,
      'VolumesFrom' => container_volumes(container),
      'CapAdd' => container_capabilities(container),
      'OomKillDisable' => false,
      'LogConfig' => log_config(container),
      'PublishAllPorts' => false,
      'Privileged' => container.is_privileged?,
      'ReadonlyRootfs' => false,
      'Dns' => container_get_dns_servers(container),
      'DnsSearch' => container_dns_search(container),
      'NetworkMode' => container_network_mode(container),
      'RestartPolicy' => restart_policy(container)
    }
  end

  def restart_policy(container)
    if ! container.restart_policy.nil?
      container.restart_policy
    elsif container.ctype == 'system_service'
      {'Name' => 'unless-stopped'}
    elsif container.ctype == 'service'
      {'Name' => 'on-failure', 'MaximumRetryCount' => 2}
    else
      {}
    end
  end

  def log_config(container)
    if container.ctype == 'service'
      { "Type" => 'json-file', "Config" => { "max-size" =>"5m", "max-file" => '10' } }
    elsif container.ctype == 'system_service'
      { "Type" => 'json-file', "Config" => { "max-size" =>"1m", "max-file" => '20' } }
    else
      { "Type" => 'json-file', "Config" => { "max-size" =>"1m", "max-file" => '5' } }
    end
  end

  def add_capabilities(capabilities)
    #    r = []
    #    capabilities.each do |capability|
    #      r += capability
    capabilities
  end

  def port_bindings(container)
    bindings = {}
    unless container.mapped_ports.nil?
      container.mapped_ports.each_value do |port|
        port = symbolize_keys(port)
        if port[:port].is_a?(String) && port[:port].include?('-')
          add_port_range(bindings, port)
        else
          add_mapped_port(bindings, port)
        end
      end
    end
    bindings
  end

  def hostname(container)
    #  return nil if container.on_host_net? == true
    if container.hostname.nil?
      container.container_name
    else
      container.hostname
    end
  end

  def container_domain_name(container)
    SystemConfig.internal_domain# if container.on_host_net? == false
  end

  def build_top_level(container)
    top_level = {
      'User' => '',
      'AttachStdin' => false,
      'AttachStdout' => false,
      'AttachStderr' => false,
      'Tty' => false,
      'OpenStdin' => false,
      'StdinOnce' => false,
      'Env' => envs(container),
      #  'Entrypoint' => entry_point(container),
      'Image' => container.image,
      'Labels' => get_labels(container),
      'Volumes' => {},
      'WorkingDir' => '',
      'NetworkDisabled' => false,

      'StopSignal' => 'SIGTERM',
      #       "StopTimeout": 10,
      'Hostname' => hostname(container),
      'Domainname' => container_domain_name(container),
      'HostConfig' => host_config_options(container)
    }
    top_level['ExposedPorts'] = exposed_ports(container) unless container.on_host_net?
    top_level['HostConfig']['PortBindings'] = port_bindings(container) unless container.on_host_net?
    #  top_level['Hostname'] = hostname(container) #unless hostname(container).nil?
    # top_level['Domainame'] = container_domain_name(container)# unless container_domain_name(container).nil?

    set_entry_point(container, top_level)
    # STDERR.puts(' CREATE ' + top_level.to_json)
    top_level
  end

  def set_entry_point(container, top_level)
    command =  container.command
    unless container.conf_self_start
      command = ['/bin/bash' ,'/home/start.bash'] if container.command.nil?
      top_level['Entrypoint'] = command
    end
  end

  def get_labels(container)
    {
      'container_name'  => container.container_name,
      'container_type' => container.ctype
    }
  end

  def cert_mounts(container)
    unless container.no_cert_map == true
      unless container.ctype == 'system_service'
        prefix =  container.ctype + 's'
      else
        prefix='services'
      end
      store = prefix + '/' + container.container_name + '/'
      [SystemConfig.CertAuthTop + store + 'certs:' + SystemConfig.CertificatesDestination + ':ro',
        SystemConfig.CertAuthTop + store + 'keys:' + SystemConfig.KeysDestination + ':ro']
    else
      nil
    end
  end

  def registry_mounts(container)
    mounts = []
    vols = container.attached_services(
    {type_path: 'filesystem/local/filesystem'
    })
    unless vols.nil
      vols.each do | vol |
        STDERR.puts( ' VOL ' + vol.to_s)
      end
    end
    mounts
  end

  def system_mounts(container)
    mounts = []
    if container.ctype == 'app'
      mounts_file_name = SystemConfig.ManagedEngineMountsFile
    else
      mounts_file_name = SystemConfig.ManagedServiceMountsFile
    end
    mounts_file = File.open(mounts_file_name, 'r')
    volumes = YAML::load(mounts_file)
    mounts_file.close

    volumes.each_value do |volume|
      mounts.push(mount_string(volume))
    end

    mounts.push(state_mount(container))
    mounts.push(logdir_mount(container))
    mounts.push(vlogdir_mount(container)) unless in_container_log_dir(container) == '/var/log' || in_container_log_dir(container) == '/var/log/'
    mounts.push(ssh_keydir_mount(container))
    cm = cert_mounts(container)
    mounts.push(kerberos_mount(container)) if container.kerberos == true
    mounts.concat(cm) unless cm.nil?
    mounts
  end

  def ssh_keydir_mount(container)
    ContainerStateFiles.container_ssh_keydir(container) + ':/home/home_dir/.ssh:rw'
  end

  def kerberos_mount(container)
    ContainerStateFiles.kerberos_dir(container) + ':/etc/krb5kdc/keys/:ro'
  end

  def vlogdir_mount(container)
    container_local_log_dir(container) + ':/var/log/:rw'
  end

  def logdir_mount(container)
    container_local_log_dir(container) + ':' + in_container_log_dir(container) + ':rw'
  end

  def state_mount(container)
    container_state_dir(container) + '/run:/home/engines/run:rw'
  end

  def container_state_dir(container)
    ContainerStateFiles.container_state_dir(container)
  end

  def container_local_log_dir(container)
    SystemConfig.SystemLogRoot + '/' + container.ctype + 's/' + container.container_name
  end

  def service_sshkey_local_dir(container)
    '/opt/engines/etc/ssh/keys/' + container.ctype + 's/' + container.container_name
  end

  def in_container_log_dir(container)
    if container.framework.nil? || container.framework.length == 0
      '/var/log'
    else
      container_logdetails_file_name = false
      framework_logdetails_file_name = SystemConfig.DeploymentTemplates + '/' + container.framework + '/home/LOG_DIR'
      SystemDebug.debug(SystemDebug.docker, 'Frame logs details', framework_logdetails_file_name)
      if File.exist?(framework_logdetails_file_name)
        container_logdetails_file_name = framework_logdetails_file_name
      else
        container_logdetails_file_name = SystemConfig.DeploymentTemplates + '/global/home/LOG_DIR'
      end
      SystemDebug.debug(SystemDebug.docker,'Container log details', container_logdetails_file_name)
      begin
        container_logdetails = File.read(container_logdetails_file_name)
      rescue
        container_logdetails = '/var/log'
      end
      container_logdetails
    end
  end

  def envs(container)
    envs = system_envs(container)
    container.environments.each do |env|
      next if env.build_time_only
      env.value ='NULL!' if env.value.nil?
      env.name = 'NULL' if env.name.nil?
      envs.push(env.name.to_s + '=' + env.value.to_s)
    end
    envs
  end

  def system_envs(container)
    envs = ['CONTAINER_NAME=' + container.container_name]
    envs
  end

  def add_port_range(bindings, port)
    internal = port[:port].split('-')
    p = internal[0].to_i
    end_port = internal[1].to_i
    while p < end_port
      add_mapped_port(bindings,{:port=> p, :external=>p, :proto_type=>get_protocol_str(port)})
      p+=1
    end
  end

  def expose_port_range(eports, port)
    internal = port[:port].split('-')
    p = internal[0].to_i
    end_port = internal[1].to_i
    while p < end_port
      add_exposed_port(eports,{:port=> p, :external=>p, :proto_type=>get_protocol_str(port)})
      p+=1
    end
  end

  def add_mapped_port(bindings, port )
    local_side = port[:port].to_s + '/' + get_protocol_str(port)
    remote_side = []
    remote_side[0] = {}
    remote_side[0]['HostPort'] = port[:external].to_s unless port[:external] == 0
    bindings[local_side] = remote_side
  end

  def add_exposed_port(eports, port)
    port[:proto_type] = 'tcp' if port[:proto_type].nil?
    if port[:proto_type].downcase.include?('and') || port[:proto_type].downcase == 'both'
      eports[port[:port].to_s + '/tcp'] = {}
      eports[port[:port].to_s + '/udp'] = {}
    else
      eports[port[:port].to_s + '/' + get_protocol_str(port)] = {}
    end
  end
end