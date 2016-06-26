module DockerApiCreateOptions
  def initialize
    @top_level = nil
  end

  def create_options(container)
    @top_level = build_top_level(container)
    @top_level['Env'] = envs(container)
  #  @top_level['Mounts'] = volumes_mounts(container)
    @top_level['ExposedPorts'] = exposed_ports(container)
    @top_level['HostConfig'] = host_config_options(container)
    return @top_level
  rescue StandardError => e
    log_exception(e)
  end

  def get_protocol_str(port)
    return  'tcp'  if port[:proto_type].nil?
    return  'both' if port[:proto_type].downcase.include?('and')
    port[:proto_type]
  end

  def exposed_ports(container)
    eports = {}
    return eports if container.mapped_ports.nil?
    STDERR.puts(' Mapped Ports to expose ' + container.mapped_ports.to_s)
    container.mapped_ports.each_value do |port|
      STDERR.puts(' exposing ' + port.to_s)
      eports[port[:port].to_s + '/' + get_protocol_str(port)] = {}
    end
    eports
  end

  def volumes_mounts(container)
    mounts = []
    container.volumes.each_value do |volume|
      mounts.push(mount_string(volume))
    end
    mounts.concat(system_mounts(container))
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
#    mount_string = {}
#    mount_string['Source'] = volume[:localpath]
#    mount_string['Destination'] = volume[:remotepath]
#    mount_string['Mode'] = volume[:permissions] + ',Z'
#    if volume[:permissions] == 'rw'
#      mount_string['RW'] = true
#    else
#      mount_string['RW'] = false
#    end
#    mount_string
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

  def host_config_options(container)

    host_config = {}
    host_config['Binds'] = volumes_mounts(container)
    host_config['PortBindings'] = port_bindings(container)
    host_config['Volumes'] = {}
    #  host_config['LxcConf'] # {"lxc.utsname":"docker"},
      memory = container.memory.to_i * 1024 * 1024
    host_config['Memory'] = memory
    host_config['MemorySwap'] = memory * 2  
    host_config['MemoryReservation'] # 0,
    # host_config['KernelMemory'] # 0,
    #  host_config['CpuShares'] # 512,
    # host_config['CpuPeriod'] # 100000,
    #   host_config['CpuQuota'] # 50000,
    #   host_config['CpusetCpus'] # "0,1",
    #   host_config['CpusetMems'] # "0,1",
    #     host_config['BlkioWeight'] # 300,
    #host_config['MemorySwappiness'] # 60,
    host_config['OomKillDisable'] = false

    host_config['PublishAllPorts'] = false
    host_config['Privileged'] = false
    host_config['ReadonlyRootfs'] = false
    host_config['Dns'] = get_dns_servers
    # host_config['DnsOptions'] # [""],
    host_config['DnsSearch'] = get_dns_search
    #host_config['ExtraHosts'] # null,
    #   host_config['VolumesFrom'] # ["parent", "other:ro"],
    #   host_config['CapAdd'] # ["NET_ADMIN"],
    #   host_config['CapDrop'] # ["MKNOD"],
    #   host_config['RestartPolicy'] # { "Name": "", "MaximumRetryCount": 0 },
    if container.on_host_net? == false
      host_config['NetworkMode'] = 'bridge'
    else
      host_config['NetworkMode'] ='host'
    end
    #      host_config['Devices'] # [],
    #      host_config['Ulimits'] # [{}],
    #   host_config['LogConfig'] = Hash.new ( "Type": "json-file", "Config": {} )
#    host_config['SecurityOpt']= ""
#    host_config['CgroupParent'] = ""
#    host_config['VolumeDriver'] = ""

    host_config
  end

  def port_bindings(container)
    bindings = {}
    return bindings if container.mapped_ports.nil?
    container.mapped_ports.each_value do |port|
      local_side =     port[:port].to_s + '/' + get_protocol_str(port)
      remote_side = []
      remote_side[0] = {}
      remote_side[0]['HostPort'] = port[:external].to_s
      bindings[local_side] = remote_side
    end
    bindings
  end

  def build_top_level(container)
    top_level = {}
    top_level['Hostname'] = container.hostname
    top_level['Domainame'] =  container.domain_name
    top_level['AttachStdin'] = false
    top_level['AttachStdout'] = false
    top_level['AttachStderr'] = false
    top_level['Tty'] = false
    top_level['OpenStdin'] = false
    top_level['StdinOnce'] = false
    top_level['Labels'] = {}
    top_level['WorkingDir'] = ''
    top_level['User'] = ''
    top_level['NetworkDisabled'] = false
    top_level['StopSignal'] = 'SIGTERM'
    top_level['Image']=  container.image
    top_level['Entrypoint'] =  ['/bin/bash' ,'/home/start.bash'] unless container.conf_self_start
    top_level
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

    return mounts
  end

  def ssh_keydir_mount(container)
    service_sshkey_local_dir(container) + ':/home/.ssh:rw'
#    ssh_keydir_mount_string = {}
#    ssh_keydir_mount_string['Source'] = service_sshkey_local_dir(container)
#    ssh_keydir_mount_string['Destination'] = '/home/.ssh'
#    ssh_keydir_mount_string['Mode'] = 'rw,Z'
#    ssh_keydir_mount_string['RW'] = true
#    ssh_keydir_mount_string
  end

  def vlogdir_mount(container)
    container_local_log_dir(container) + ':/var/log/:rw'
#    vlogdir_mount_string = {}
#    vlogdir_mount_string['Source'] = container_local_log_dir(container)
#    vlogdir_mount_string['Destination'] = '/var/log/'
#    vlogdir_mount_string['Mode'] = 'rw,Z'
#    vlogdir_mount_string['RW'] = true
#    vlogdir_mount_string
  end

  def logdir_mount(container)
    container_local_log_dir(container) + ':' + in_container_log_dir(container) + ':rw'
#    logdir_mount_string = {}
#    logdir_mount_string['Source'] = container_local_log_dir(container)
#    logdir_mount_string['Destination'] = in_container_log_dir(container)
#    logdir_mount_string['Mode'] = 'rw,Z'
#    logdir_mount_string['RW'] = true
#    logdir_mount_string
  end

  def state_mount(container)
    container_state_dir(container) + '/run:/engines/var/run:rw'
#    state_mount_string = {}
#    state_mount_string['Source'] = container_state_dir(container) + '/run'
#    state_mount_string['Destination'] = '/engines/var/run'
#    state_mount_string['Mode'] = 'rw,Z'
#    state_mount_string['RW'] = true
#    state_mount_string
  end

  def container_state_dir(container)
    ContainerStateFiles.container_state_dir(container)
  end

  def container_local_log_dir(container)
    SystemConfig.SystemLogRoot + '/' + container.ctype + 's/' + container.container_name
  end

  def service_sshkey_local_dir(container)
    '/opt/engines/etc/ssh/keys/services/' + container.container_name
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
    return container_logdetails
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
end