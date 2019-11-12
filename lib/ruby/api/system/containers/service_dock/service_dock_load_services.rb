module ServiceDockLoadServices
  def load_and_attach_pre_services(c)
    dirname = "#{container_services_dir(c)}/pre/"
    core.load_and_attach_static_services(dirname, c)
  end

  def load_and_attach_shared_services(c)
    dirname = "#{container_services_dir(c)}/shared/"
    core.load_and_attach_static_services(dirname, c)
  end

  def load_and_attach_post_services(c)
   # SystemDebug.debug(SystemDebug.services,:load_and_attach_post_services,container.container_name)
    dirname = "#{container_services_dir(c)}/post/"
    core.load_and_attach_static_services(dirname, c)
  end

end
