module ServiceDockSystem
  def create_container(c)
    setup_service_dirs(c.container_name)
    super(c)
  end

  def setup_service_dirs(cn)
    #  STDERR.puts(' SSEETTUUPP ' + container.container_name + ' with ' + '/opt/engines/system/scripts/system/setup_service_dir.sh ' + container.container_name)
  SystemUtils.execute_command("/opt/engines/system/scripts/system/setup_service_dir.sh #{cn}")
  end

  def container_services_dir(c)
    "#{c.store.container_state_dir(c.container_name)}/services/"
  end

end