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

  secrets = secrets_mounts(container)
  mounts.concat(secrets) unless secrets.nil?

  unless container.ctype == 'system_service'
    rm = registry_mounts(container)
    mounts.concat(rm) unless rm.nil?
  end
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
    prefix =  container.ctype + 's'
    store = prefix + '/' + container.container_name + '/'
    [SystemConfig.CertAuthTop + store + 'certs:' + SystemConfig.CertificatesDestination + ':ro',
      SystemConfig.CertAuthTop + store + 'keys:' + SystemConfig.KeysDestination + ':ro']
  else
    nil
  end
end

def get_local_prefix(vol)
  unless vol[:variables][:volume_src].start_with?('/var/lib/engines/apps/') == true  || vol[:variables][:volume_src].start_with?('/var/lib/engines/services/') == true
    unless vol[:shared] == true
      '/var/lib/engines/' + vol[:container_type] + 's/' + vol[:parent_engine] + '/' +  vol[:service_handle] + '/'
    else
      '/var/lib/engines/' + vol[:container_type] + 's/' + vol[:service_owner] + '/' +  vol[:service_owner_handle] + '/'
    end
  else
    ''
  end
rescue Exception => e
  STDERR.puts('EXCEPTION:'+ e.to_s + ' With ' + vol.to_s)
  raise e
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
rescue Exception => e
  STDERR.puts('EXCEPTION:'+ e.to_s + ' With ' + vol.to_s)
  raise e
end

def  mount_string_from_hash(vol)
  unless vol[:variables][:permissions].nil? || vol[:variables][:volume_src].nil?  || vol[:variables][:engine_path].nil?
    perms = 'ro'
    if vol[:variables][:permissions] == 'rw'
      perms = 'rw'
    else
      perms = 'ro'
    end
    vol[:variables][:volume_src].strip!
    vol[:variables][:volume_src].gsub!(/[ \t]*$/,'')
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
  if vols.is_a?(Array)
    vols.each do | vol |
      v_str = mount_string_from_hash(vol)
      mounts.push(v_str)
    end
  else
    STDERR.puts('Registry mounts was' + vols.to_s)
  end

  mounts
end

def  mount_string_for_secret(secret)

  if secret[:shared] == true
    src_cname =  secret[:service_owner]
    src_ctype =  secret[:container_type]
    sh = secret[:service_owner_handle]
  else
    src_cname =  secret[:parent_engine]
    src_ctype =  secret[:container_type]
    sh = secret[:service_handle]
  end
  STDERR.puts('Secrets mount' +  '/var/lib/engines/secrets/' + src_ctype.to_s + 's/' +  src_cname.to_s + '/' + sh.to_s + ':/home/.secrets/'  + sh.to_s + ':ro')
  s = '/var/lib/engines/secrets/' + src_ctype + 's/' +  src_cname + '/' + sh +\
  ':/home/.secrets/'  + sh + ':ro'
  STDERR.puts('Secrets mount' + s.to_s)
  s
end

def secrets_mounts(container)
  mounts = []
  secrets = container.attached_services(
  {type_path: 'secrets'
  })
  if secrets.is_a?(Array)
    secrets.each do | secret |
      m_str = mount_string_for_secret(secret)
      mounts.push(m_str)
    end
  else
    STDERR.puts('Secrets mounts was' + secrets.to_s)
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

def secrets_mount(container)
  ContainerStateFiles.container_secretsdir(container) + ':/home/.secrets:ro'
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