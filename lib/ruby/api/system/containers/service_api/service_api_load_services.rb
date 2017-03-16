module ServiceApiLoadServices
  def load_and_attach_pre_services(container)
    dirname = container_services_dir(container) + '/pre/'

    engines_core.load_and_attach_services(dirname, container)
  end

  def load_and_attach_shared_services(container)
    dirname = container_services_dir(container) + '/shared/'
    engines_core.load_and_attach_services(dirname, container)
  end

  def load_and_attach_post_services(container)
    SystemDebug.debug(SystemDebug.services,:load_and_attach_post_services,container.container_name)
    dirname = container_services_dir(container) + '/post/'
    engines_core.load_and_attach_services(dirname, container)
  end

end