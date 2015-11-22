module ServiceApiSystem
  def create_container(container)
    SystemUtils.execute_command('/opt/engines/scripts/setup_service_dir.sh ' + container.container_name)
    super
  end

  def container_services_dir(container)
    ContainerStateFiles.container_state_dir(container) + '/services/'
  end

end