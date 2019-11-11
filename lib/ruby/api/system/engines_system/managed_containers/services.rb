require '/opt/engines/lib/ruby/containers/store/service_store'
require '/opt/engines/lib/ruby/containers/store/system_service_store'

module Services
  def getManagedServices
    service_store.all
  end

  def getSystemServices
    system_service_store.all
  end

  def list_managed_services
    service_store.all_names
  end

  def list_system_services
    system_service_store.all_names
  end

  def loadSystemService(name)
    system_service_store.model(name)
  end

  def loadManagedService(name)
    service_store.model(name)
  end

  protected

  def service_store
    Container::ManagedService.store
  end

  def system_service_store
    Container::SystemService.store
  end

  private

  def setup_service_dirs(container)
    run_server_script('setup_service_dir', container.container_name)
  end
end
