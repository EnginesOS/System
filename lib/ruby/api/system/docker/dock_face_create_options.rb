class DockFaceCreateOptions
#  def initialize
#    @top_level = nil
#  end
  class << self
#  require '/opt/engines/lib/ruby/api/system/container_state_files.rb'

  require_relative 'create_options/mount_options.rb'
  require_relative 'create_options/ports.rb'
  require_relative 'create_options/dns.rb'

  def create_options(c)
  #  @top_level = build_top_level(c)
    build_top_level(c)
  end

  def get_protocol_str(port)
    if port[:proto_type].nil?
      'tcp'
    else
      port[:proto_type]
    end
  end

  def container_memory(c)
    c.memory.to_i * 1024 * 1024
  end

  def container_capabilities(c)
    unless c.capabilities.nil?
      add_capabilities(c.capabilities)
    else
      []
    end
  end

  def host_config_options(c)
    {
      'Binds' => volumes_mounts(c),
      'Memory' => container_memory(c),
      'MemorySwap' => container_memory(c) * 2,
      'VolumesFrom' => container_volumes(c),
      'CapAdd' => container_capabilities(c),
      'OomKillDisable' => false,
      'LogConfig' => log_config(c),
      'PublishAllPorts' => false,
      'Privileged' => c.is_privileged?,
      'ReadonlyRootfs' => false,
      'Dns' => container_get_dns_servers(c),
      'DnsSearch' => container_dns_search(c),
      'NetworkMode' => container_network_mode(c),
      'RestartPolicy' => restart_policy(c)
    }
  end

  def restart_policy(c)
    if ! c.restart_policy.nil?
      c.restart_policy
    elsif c.ctype == 'system_service'
      {'Name' => 'unless-stopped'}
    elsif c.ctype == 'service'
      #{'Name' => 'on-failure', 'MaximumRetryCount' => 4}
      {'Name' => 'no'}
    else
      {}
    end
  end

  def log_config(c)
    case c.ctype
    when 'service'
      { "Type" => 'json-file', "Config" => { "max-size" =>"5m", "max-file" => '10' } }
    when 'system_service'
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

  def container_network_mode(c)
    if c.on_host_net? == false
      'bridge'
    else
      'host'
    end
  end

  def io_attachments(c, top)
    unless c.accepts_stream?
      top['AttachStdin'] = false
    else
      top['AttachStdin'] = true
    end
    unless c.provides_stream?
      top['AttachStdout'] = false
      top['AttachStderr'] = false
    else
      top['AttachStdout'] = true
      top['AttachStderr'] = true
    end

    top['OpenStdin'] = false
    top['StdinOnce'] = false
  end

  def build_top_level(c)
    top_level = {
      'User' => '',
      'Tty' => false,
      'Env' => envs(c),
      'Image' => c.image,
      'Labels' => get_labels(c),
      'Volumes' => {},
      'WorkingDir' => '',
      'NetworkDisabled' => false,
      'StopSignal' => 'SIGTERM',
      #       "StopTimeout": 10,
      'Hostname' => hostname(c),
      'Domainname' => container_domain_name(c),
      'HostConfig' => host_config_options(c)
    }
    io_attachments(c, top_level)
    top_level['ExposedPorts'] = exposed_ports(c) unless c.on_host_net?
    top_level['HostConfig']['PortBindings'] = port_bindings(c) unless c.on_host_net?
    set_entry_point(c, top_level)
    STDERR.puts('Options:' + top_level.to_s)
    top_level
  end

  def set_entry_point(c, top_level)
    command =  c.command
    unless c.conf_self_start
      command = ['/bin/bash' ,'/home/engines/scripts/startup/start.sh'] if c.command.nil?
      top_level['Entrypoint'] = command
    end
  end

  def get_labels(c)
    {
      'container_name'  => c.container_name,
      'container_type' => c.ctype
    }
  end

  def envs(c)
    envs = system_envs(c)
    c.environments.each do |env|
      next if env.build_time_only
      env.value ='NULL!' if env.value.nil?
      env.name = 'NULL' if env.name.nil?
      envs.push("#{env.name}=#{env.value}")
    end
    envs
  end

  def system_envs(c)
    envs = []
    envs[0] = "CONTAINER_NAME=#{c.container_name}"
    envs[1] = "KRB5_KTNAME=/etc/krb5kdc/keys/#{c.container_name}.keytab" if c.kerberos == true
    envs
  end
  end

end