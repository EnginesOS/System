# Configurations methods
module Configurations
 # require_relative 'xcon_rset.rb'
  def get_service_configurations_hashes(config_hash)
    rest_get('/v0/system_registry/service/configurations/' + config_hash[:service_name] )
    rescue StandardError => e
       STDERR.puts( 'Failed To /v0/system_registry/service/configurations/  ' + config_hash.to_s)
        SystemUtils.log_exception(e)
  end

  def get_service_configuration(config_hash)
    rest_get('/v0/system_registry/services/configuration/' + config_hash[:service_name] + '/' + config_hash[:configurator_name] )
    rescue StandardError => e
       STDERR.puts( 'Failed To /v0/system_registry/services/configuration/  ' + config_hash.to_s)
        SystemUtils.log_exception(e)
  end

  def update_service_configuration(config_hash)
    rest_post('/v0/system_registry/services/configuration/update/' + config_hash[:service_name] + '/' + config_hash[:configurator_name] , {:api_vars => config_hash} )
    rescue StandardError => e
       STDERR.puts( 'Failed To /v0/system_registry/services/configuration/update/  ' + config_hash.to_s)
        SystemUtils.log_exception(e)
  end

  def rm_service_configuration(config_hash)
    rest_delete('/v0/system_registry/services/configurations/del/' + config_hash[:service_name] + '/' + config_hash[:configurator_name]  )
    rescue StandardError => e
       STDERR.puts( 'Failed To /v0/system_registry/services/configurations/del/  ' + config_hash.to_s)
        SystemUtils.log_exception(e)
  end

  def add_service_configuration(config_hash)
    rest_post('/v0/system_registry/services/configurations/add/' + config_hash[:service_name] + '/' + config_hash[:configurator_name] , {:api_vars => config_hash} )
    rescue StandardError => e
       STDERR.puts( 'Failed To /v0/system_registry/services/configurations/add/  ' + config_hash.to_s)
        SystemUtils.log_exception(e)
  end

  def service_configurations_registry
    rest_get('/v0/system_registry/services/configurations/tree', nil)
  end
end