# Configurations methods
module Configurations
  def get_service_configurations_hashes(config_hash)
    r = 'service/configurations'
    r += address_params(config_hash,[:service_name] )
    rest_get(r)
  rescue StandardError => e
    STDERR.puts( 'Failed To service/configurations/ ' + config_hash.to_s)
    SystemUtils.log_exception(e)
  end

  def get_service_configuration(config_hash)
    r = 'service/configurations'
    r += address_params(config_hash,[:service_name,:configurator_name] )
    rest_get(r)
  rescue StandardError => e
    STDERR.puts( 'Failed To services/configuration/ ' + config_hash.to_s)
    SystemUtils.log_exception(e)
  end

  def update_service_configuration(config_hash)
    r = 'service/configuration/update'
    r += address_params(config_hash,[:service_name,:configurator_name] )
    rest_post(r, {:api_vars => config_hash})
  rescue StandardError => e
    STDERR.puts( 'Failed To services/configuration/update/  ' + config_hash.to_s)
    SystemUtils.log_exception(e)
  end

  def rm_service_configuration(config_hash)
    r = 'service/configurations/del'
    r += address_params(config_hash,[:service_name,:configurator_name] )
    rest_delete(r)

  rescue StandardError => e
    STDERR.puts( 'Failed To services/configurations/del/ ' + config_hash.to_s)
    SystemUtils.log_exception(e)
  end

  def add_service_configuration(config_hash)
    r = 'service/configurations/add'
    r += address_params(config_hash,[:service_name,:configurator_name] )
    rest_post(r, {:api_vars => config_hash})
  rescue StandardError => e
    STDERR.puts( 'Failed add To services/configurations/add/ ' + config_hash.to_s)
    SystemUtils.log_exception(e)
  end

  def service_configurations_registry
    rest_get('services/configurations/tree', nil)
  end
end