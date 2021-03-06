# Configurations methods
class SystemRegistryClient
  def retrieve_service_configurations(config_hash)
    r = 'service/configurations'
    r += address_params(config_hash, [:service_name])
    rest_get(r)
  end

  def retrieve_service_configuration(config_hash)
    r = "service/configuration#{address_params(config_hash, [:service_name, :configurator_name])}"
    rest_get(r)
  end

  def update_service_configuration(config_hash)
    r = 'service/configuration/update'
    r += address_params(config_hash, [:service_name, :configurator_name])
    post(r, {:api_vars => config_hash})
  end

  def rm_service_configuration(config_hash)
    r = 'service/configurations/del'
    r += address_params(config_hash, [:service_name, :configurator_name])
    delete(r)
  end

  def add_service_configuration(config_hash)
    r = 'service/configurations/add'
    r += address_params(config_hash, [:service_name, :configurator_name])
    post(r, {:api_vars => config_hash})
  end

  def service_configurations_registry
    rest_get('services/configurations/tree', nil)
  end
end