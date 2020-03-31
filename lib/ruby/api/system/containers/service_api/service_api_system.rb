module ServiceApiSystem
  def create_container(container)
    setup_service_dirs(container)
    super(container)
  end

  def setup_service_dirs(container)
    #  STDERR.puts(' SSEETTUUPP ' + container.container_name + ' with ' + '/opt/engines/system/scripts/system/setup_service_dir.sh ' + container.container_name)
  SystemUtils.execute_command("/opt/engines/system/scripts/system/setup_service_dir.sh #{container.container_name}")
  end

  def container_services_dir(ca)
    "#{ContainerStateFiles.container_state_dir(ca)}/services/"
  end

end