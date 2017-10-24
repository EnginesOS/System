module ServiceApiSystem
  def create_container(container)
    setup_service_dirs(container)
    super(container)
  end

  def setup_service_dirs(container)
    #  STDERR.puts(' SSEETTUUPP ' + container.container_name + ' with ' + '/opt/engines/system/scripts/system/setup_service_dir.sh ' + container.container_name)
    SystemUtils.execute_command('/opt/engines/system/scripts/system/setup_service_dir.sh ' + container.container_name)
    #  SystemUtils.execute_command('ls -la /opt/engines/run/services/' + container.container_name + ' >> /tmp/perms')
  end

  def container_services_dir(container)
    @system_api.container_state_dir(container) + '/services/'
  end

end