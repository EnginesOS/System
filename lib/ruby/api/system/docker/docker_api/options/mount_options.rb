def container_volumes(container)
  unless container.volumes_from.nil?
    container.volumes_from
  else
    []
  end
end

def volumes_mounts(container)
  mounts = []
  unless container.volumes.nil?
    container.volumes.each_value do |volume|
      mounts.push(mount_string(volume))
    end
  end
  sm = system_mounts(container)
  mounts.concat(sm) unless sm.nil?
  rm = registry_mounts(container)
  mounts.concat(rm) unless rm.nil?
  mounts
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

def get_local_prefix(vol)
  unless vol[:shared] == true
    '/var/lib/engines/' + vol[:container_type] + 's/' + vol[:parent_engine] + '/' +  vol[:service_handle] + '/'
  else
    '/var/lib/engines/' + vol[:container_type] + 's/' + vol[:service_owner] + '/' +  vol[:service_name] + '/'
  end
end
def get_remote_prefix(vol)
  if  vol[:container_type] == 'app'
  unless vol[:variables][:engine_path].start_with?('/home/app/') || vol[:variables][:engine_path].start_with?('/home/fs/')
    '/home/fs/' 
  else
   ''
  end
  else
     unless vol[:variables][:engine_path].start_with?('/')
       '/'
     else
       ''
     end     
  end
end
def  mount_string_from_hash(vol)
  unless vol[:variables][:permissions].nil? || vol[:variables][:volume_src].nil?  ||vol[:variables][:engine_path].nil?
    perms = 'ro'
    if vol[:variables][:permissions] == 'rw'
      perms = 'rw'
    else
      perms = 'ro'
    end    
    STDERR.puts('_' + vol[:variables][:volume_src].to_s + '_')
    vol[:variables][:volume_src].strip!
    get_local_prefix(vol) + vol[:variables][:volume_src] + ':' + get_remote_prefix(vol) + vol[:variables][:engine_path] + ':' + perms
  else
    STDERR.puts('missing keys in vol ' + vol.to_s )
    ''
  end
end

def registry_mounts(container)
  mounts = []
  vols = container.attached_services(
  {type_path: 'filesystem/local/filesystem'
  })
  unless vols.nil?
    vols.each do | vol |
      v_str = mount_string_from_hash(vol)
      STDERR.puts( ' VOL ' + v_str.to_s)
      mounts.push(v_str)
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