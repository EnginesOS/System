module ServiceConsumers
  include CoreAccess
  def load_and_attach_persistant_services(container)
    dirname = container_services_dir(container) + '/pre/'
    engines_core.load_and_attach_services(dirname, container)
  end

  def load_and_attach_shared_services(container)
    dirname = container_services_dir(container) + '/shared/'
    engines_core.load_and_attach_services(dirname, container)
  end

  def load_and_attach_nonpersistant_services(container)
    dirname = container_services_dir(container) + '/post/'
    engines_core.load_and_attach_services(dirname, container)
  end

  def get_registered_against_service(params)
    engines_core.get_registered_against_service(params)
  end
end