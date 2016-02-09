module DockerApiCreateOptions
  def initialize
  @top_level = nil
  end
  
  def create_options(container)
    @top_level = build_top_level(container)
    @top_level['Env'] = envs(container)
    @top_level['Mounts'] = volumes_mounts(container)
    @top_level['ExposedPorts'] = exposed_ports(container)
    @top_level['HostConfig'] = host_config_options(container)
    return @top_level
    
  end
  
  def get_protocol_str(port)
    return  'tcp'  if port.proto_type.nil?
    return  'both' if eport.proto_type.downcase.include?('and')
    port.proto_type
  end
  
  def exposed_ports(container)
    eports = {}
    container.ports.each do |port|
    eports[port.to_s + '/' + get_protocol_str(port)] = {}
    end         
    eports
  end
  
  def volumes_mounts(container)
    mounts = []
      container.volumes.each_value do |volume|        
        mounts.push(mount_hash(volume))
      end
      mounts.concat(system_mounts(container))
     mounts
   end
   
   def mount_hash(volume)
     mount_hash = {}
     mount_hash['Source'] = volume.localpath
     mount_hash['Destination'] = volume.remotepath   
     mount_hash['Mode'] = volume.mapping_permissions + ',Z'
     if volume.mapping_permissions == 'rw'
      mount_hash['RW'] = true
     else
       mount_hash['RW'] = false
     end
   end
   
   def get_dns_search
     search = []
       search.push(SystemConfig.internal_domain)
       search
   end
   
   def get_dns_servers
     servers = []
     servers.push( SystemStatus.get_management_ip)
     servers
   end

   
   def host_config_options(container)
     
     host_config = {}
     host_config['PortBindings'] = port_bindings(container)
   #  host_config['LxcConf'] # {"lxc.utsname":"docker"},
     host_config['Memory'] = container.memory.to_s
     host_config['MemorySwap'] = (container.memory * 2).to_s
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
      host_config['SecurityOpt']= ""
      host_config['CgroupParent'] = ""
      host_config['VolumeDriver'] = ""
           
       
      host_config 
   end
   
   def port_bindings(container)
     bindings = {}
         container.ports.each do |port|             
           local_side =     port.port.to_s + '/' + get_protocol_str(port)
           remote_side = []
         remote_side[0] = {}
         remote_side[0]['HostPort'] = port.external.to_s
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
      
    top_level['WorkingDir'] = ''
    top_level['NetworkDisabled'] = false
    top_level['StopSignal'] = 'SIGTERM'
    top_level['WorkingDir'] = ''
    top_level['Image']=  container.image
    top_level['Entrypoint'] =  ' /bin/bash /home/start.bash' unless container.conf_self_start    
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
    volumes.each do |volume|
      mounts.push(mount_hash(volume))
    end
    
    mounts.push(state_mount(container))
    mounts.push(logdir_mount(container))
    mounts.push(vlogdir_mount(container)) unless container_log_dir(container) == '/var/log' || container_log_dir(container) == '/var/log/'
    mounts.push(ssh_keydir_mount(container))

    return mounts
  end
  
  def ssh_keydir_mount(container)
    ssh_keydir_mount_hash = {}  
       ssh_keydir_mount_hash['Source'] = service_sshkey_container_dir(container)
       ssh_keydir_mount_hash['Destination'] = '/home/.ssh'
       ssh_keydir_mount_hash['Mode'] = 'rw,Z'
       ssh_keydir_mount_hash['RW'] = true     
    ssh_keydir_mount_hash
  end
  
  def vlogdir_mount(container)
      vlogdir_mount_hash = {}      
       vlogdir_mount_hash['Source'] = container_log_dir(container) 
       vlogdir_mount_hash['Destination'] = '/var/log/'
       vlogdir_mount_hash['Mode'] = 'rw,Z'
       vlogdir_mount_hash['RW'] = true   
    vlogdir_mount_hash
  end
  
  def logdir_mount(container)
    logdir_mount_hash = {}      
        logdir_mount_hash['Source'] = container_log_dir(container) 
        logdir_mount_hash['Destination'] = incontainer_logdir
        logdir_mount_hash['Mode'] = 'rw,Z'
        logdir_mount_hash['RW'] = true
    logdir_mount_hash
  end
  
  def state_mount(container)
    state_mount_hash = {}
        state_mount_hash['Source'] = container_state_dir(container) + '/run'
        state_mount_hash['Destination'] = '/engines/var/run'
        state_mount_hash['Mode'] = 'rw,Z'
        state_mount_hash['RW'] = true
    state_mount_hash
  end
  
    def self.container_state_dir(container)
      ContainerStateFiles.container_state_dir(container)
    end
  
    def self.container_log_dir(container)
      SystemConfig.SystemLogRoot + '/' + container.ctype + 's/' + container.container_name
    end
    
    def self.service_sshkey_local_dir(container)
      '/opt/engines/etc/ssh/keys/services/' + container.container_name
    end

    def get_container_logdir(container)
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
  def envs(container)
      envs = {}
        container.environments.each do |env|
          next if env.build_time_only
          envs[env.name] = env.value
        end
         envs
    end
end