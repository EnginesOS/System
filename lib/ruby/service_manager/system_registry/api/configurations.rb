# Configurations methods
module Configurations
  def retrieve_service_configurations(config_hash)
    r = 'service/configurations'
    r += address_params(config_hash, [:service_name])
    get(r)
  end

  def retrieve_service_configuration(config_hash)
    r = 'service/configuration'
    r += address_params(config_hash, [:service_name, :configurator_name])
    get(r)
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
    get('services/configurations/tree', nil)
  end
end