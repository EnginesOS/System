module DockerApiCreateOptions
  def initialize
    @top_level = nil
  end

  def create_options(container)
    @top_level = build_top_level(container)
    # @top_level['Env'] = envs(container)
    #  @top_level['Mounts'] = volumes_mounts(container)
   # ports = exposed_ports(container)
   # @top_level['ExposedPorts'] = ports unless ports.nil?
   # @top_level['HostConfig'] = host_config_options(container)
    # STDERR.puts('create options ' + @top_level.to_s)
    # @top_level
    STDERR.puts('create  container.on_host_net?' + container.on_host_net?.to_s)
    STDERR.puts('create options ' + @top_level.to_s)
  rescue StandardError => e
    log_exception(e)
  end

  def get_protocol_str(port)
    return  'tcp'  if port[:proto_type].nil?
    # return  'both' if port[:proto_type].downcase.include?('and')
    port[:proto_type]
  end

  def exposed_ports(container)

    return {} if container.mapped_ports.nil?
    eports = {}
    container.mapped_ports.each_value do |port|
      port = SystemUtils.symbolize_keys(port)
      if port[:port].is_a?(String) && port[:port].include?('-')
        expose_port_range(eports, port)
      else
        add_exposed_port(eports, port)
      end
    end
    eports
  end

  def volumes_mounts(container)
    mounts = []
    return system_mounts(container) if container.volumes.nil?
    container.volumes.each_value do |volume|
      mounts.push(mount_string(volume))
    end
    sm = system_mounts(container)
    mounts.concat(sm) unless sm.nil?
    cm = cert_mounts(container)
    mounts.concat(cm) unless cm.nil?
    mounts
  end

  def mount_string(volume)
    volume = SystemUtils.symbolize_keys(volume)
    perms = 'ro'
    if volume[:permissions] == 'rw'
      perms = 'rw'
    else
      perms = 'ro'
    end
    volume[:localpath] + ':' + volume[:remotepath] + ':' + perms

  rescue StandardError => e
    STDERR.puts(' vol ' + volume.to_s)
    log_exception(e, volume)
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
    return  container.volumes_from unless container.volumes_from.nil?
    ''
  end

  def container_capabilities(container)
    return add_capabilities(container.capabilities) unless container.capabilities.nil?
    ''
  end

  def container_get_dns_servers(container)
    return  get_dns_servers  if container.on_host_net? == false
    ''
  end

  def container_dns_search(container)
   return get_dns_search  if container.on_host_net? == false
    ''
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
      'PortBindings' => port_bindings(container),
      'Volumes' => {},
      'Memory' => container_memory(container),
      'MemorySwap' => container_memory(container) * 2,
      'VolumesFrom' => container_volumes(container),
      'CapAdd' => container_capabilities(container),
      'OomKillDisable' => false,
      'LogConfig' => log_config(container),
      'PublishAllPorts' => false,
      'Privileged' => false,
      'ReadonlyRootfs' => false,
      'Dns' => container_get_dns_servers(container),
      'DnsSearch' => container_dns_search(container),
      'NetworkMode' => container_network_mode(container)
    }

    #  host_config['LxcConf'] # {"lxc.utsname":"docker"},
    #'MemoryReservation' # 0,
    # "CapAdd": ["NET_ADMIN"],
    #STDERR.puts(" Add cap ");

    #  STDERR.puts(" Add caps " + host_config["CapAdd"].to_s);
    # host_config['KernelMemory'] # 0,
    #  host_config['CpuShares'] # 512,
    # host_config['CpuPeriod'] # 100000,
    #   host_config['CpuQuota'] # 50000,
    #   host_config['CpusetCpus'] # "0,1",
    #   host_config['CpusetMems'] # "0,1",
    #     host_config['BlkioWeight'] # 300,
    #host_config['MemorySwappiness'] # 60,
    # host_config['DnsOptions'] # [""],

    #      host_config['Devices'] # [],
    #      host_config['Ulimits'] # [{}],
    #   host_config['LogConfig'] = Hash.new ( "Type": "json-file", "Config": {} )
    #    host_config['SecurityOpt']= ""
    #    host_config['CgroupParent'] = ""
    #    host_config['VolumeDriver'] = ""
    #host_config['ExtraHosts'] # null,
    #   host_config['VolumesFrom'] # ["parent", "other:ro"],
    #   host_config['CapAdd'] # ["NET_ADMIN"],
    #   host_config['CapDrop'] # ["MKNOD"],
    #   host_config['RestartPolicy'] # { "Name": "", "MaximumRetryCount": 0 },
    # host_config
  end

  def log_config(container)
      return { "Type" => 'json-file', "Config" => {}}
    return { "Type" => 'json-file', "Config" => { "max-size" =>"5m", "max-file" => '10' } } if container.ctype == 'service'
    { "Type" => 'JsonFile', "Config" => { "max-size" =>"1m", "max-file" => '5' } }
  end

  def add_capabilities(capabilities)
    #    r = []
    #    capabilities.each do |capability|
    #      r += capability
    capabilities
  end

  def port_bindings(container)
    bindings = {}
    return bindings if container.mapped_ports.nil?
    container.mapped_ports.each_value do |port|
      port = SystemUtils.symbolize_keys(port)
      if port[:port].is_a?(String) && port[:port].include?('-')
        add_port_range(bindings, port)
      else
        add_mapped_port(bindings, port)
      end
    end
    bindings
  end

  def hostname(container)
    return  container.hostname if container.on_host_net? == false
    ''
  end

  def container_domain_name(container)
    return SystemConfig.internal_domain if container.on_host_net? == false
    ''
  end
  def build_top_level(container)

    top_level = {
      'Hostname' => hostname(container),
      'Domainame' =>  container_domain_name(container),
      'AttachStdin' => false,
      'AttachStdout' => false,
      'AttachStderr' => false,
      'Tty' => false,
      'OpenStdin' => false,
      'StdinOnce' => false,
      'WorkingDir' => '',
      'User' => '',
      'Labels' => get_labels(container),
      'NetworkDisabled' => false,
      'StopSignal' => 'SIGTERM',
      'Image' => container.image,
      'Env' => envs(container).to_s,
     'ExposedPorts' => exposed_ports(container),
      'HostConfig' => host_config_options(container)
    }

    command =  container.command
    command = ['/bin/bash' ,'/home/start.bash'] if container.command.nil?
    top_level['Entrypoint'] = container.command  unless container.conf_self_start
    top_level
  end

  def get_labels(container)
    labels = {}
    labels['container_name'] = container.container_name
    labels['container_type'] = container.ctype
    labels
  end

  def cert_mounts(container)

    return  unless container.certificates.is_a?(Array)
    mounts = []
    container.certificates.each do |certificate|
      prefix =  certificate[:container_type] + '_' + certificate[:parent_engine] + '_' + certificate[:variables][:cert_name]
      mounts.push(SystemConfig.CertificatesDir + prefix + '.crt:' + SystemConfig.CertificatesDestination +  certificate[:variables][:cert_name] + '.crt:ro' )
      mounts.push(SystemConfig.KeysDir + prefix + '.key:' + SystemConfig.KeysDestination +  certificate[:variables][:cert_name] + '.key:ro' )
    end
    mounts
  end

  def system_mounts(container)
    mounts = []
    if container.ctype == 'container'
      mounts_file_name =  SystemConfig.ManagedEngineMountsFile
    else
      mounts_file_name =  SystemConfig.ManagedServiceMountsFile
    end
    mounts_file = File.open(mounts_file_name,'r')
    volumes = YAML::load(mounts_file)
    mounts_file.close

    volumes.each_value do |volume|
      mounts.push(mount_string(volume))
    end

    mounts.push(state_mount(container))
    mounts.push(logdir_mount(container))
    mounts.push(vlogdir_mount(container)) unless in_container_log_dir(container) == '/var/log' || in_container_log_dir(container) == '/var/log/'
    mounts.push(ssh_keydir_mount(container))

    mounts
  end

  def ssh_keydir_mount(container)
    ContainerStateFiles.container_ssh_keydir(container) + ':/home/home_dir/.ssh:rw'
  end

  def vlogdir_mount(container)
    container_local_log_dir(container) + ':/var/log/:rw'
  end

  def logdir_mount(container)
    container_local_log_dir(container) + ':' + in_container_log_dir(container) + ':rw'
  end

  def state_mount(container)
    container_state_dir(container) + '/run:/engines/var/run:rw'
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
    return '/var/log' if container.framework.nil? || container.framework.length == 0
    container_logdetails_file_name = false
    framework_logdetails_file_name = SystemConfig.DeploymentTemplates + '/' + container.framework + '/home/LOG_DIR'
    SystemDebug.debug(SystemDebug.docker,'Frame logs details', framework_logdetails_file_name)
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
  rescue StandardError => e
    SystemUtils.log_exception(e)
  end

  def envs(container)
    envs = []
    container.environments.each do |env|
      next if env.build_time_only
      envs.push(env.name.to_s + '=' + env.value.to_s)
    end
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
    # STDERR.puts('Mapping ' + port.to_s)
    local_side =     port[:port].to_s + '/' + get_protocol_str(port)
    remote_side = []
    remote_side[0] = {}
    remote_side[0]['HostPort'] = port[:external].to_s
    bindings[local_side] = remote_side
  end

  def add_exposed_port(eports , port)

    port[:proto_type] = 'tcp' if port[:proto_type].nil?
    if port[:proto_type].downcase.include?('and') || port[:proto_type].downcase == 'both'
      eports[port[:port].to_s + '/tcp'] = {}
      eports[port[:port].to_s + '/udp'] = {}
    else
      eports[port[:port].to_s + '/' + get_protocol_str(port)] = {}
    end
  end
end