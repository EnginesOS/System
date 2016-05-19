module ServiceApiSystem
  def create_container(container)
    #setup_service_dirs
    super
  end
  def setup_service_dirs(container)
    SystemUtils.execute_command('/opt/engines/system/scripts/system/setup_service_dir.sh ' + container.container_name)
  end 
  def container_services_dir(container)
    ContainerStateFiles.container_state_dir(container) + '/services/'
  end

end