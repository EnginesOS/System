require '/opt/engines/lib/ruby/api/system/engines_core/engines_core.rb'
require '/opt/engines/lib/ruby/api/system/system_status.rb'

#require '/opt/engines/lib/ruby/system/system_config.rb'

require_relative 'engines_osapi_result.rb'
require_relative 'first_run_wizard.rb'

class EnginesOSapi

  require_relative 'engines_osapi/container_states.rb'
  include ContainerStates
  require_relative 'engines_osapi/available_services_actions.rb'
  include AvailableServicesActions
  require_relative 'engines_osapi/certificate_actions.rb'
  include CertificateActions
  require_relative 'engines_osapi/container_actions.rb'
  include ContainerActions
  require_relative 'engines_osapi/domainname_actions.rb'
  include DomainnameActions
  require_relative 'engines_osapi/engine_actions.rb'
  include EngineActions
  require_relative 'engines_osapi/engine_build_actions.rb'
  include EngineBuildActions

  require_relative 'engines_osapi/engines_system_info.rb'
  include EnginesSystemInfo
  require_relative 'engines_osapi/fetch_trees.rb'
  include FetchTrees
  require_relative 'engines_osapi/managed_service_actions.rb'
  include ManagedServiceActions
  require_relative 'engines_osapi/managed_service_direct_actions.rb'
  include ManagedServiceDirectActions
  require_relative 'engines_osapi/preference_actions.rb'
  include PreferenceActions
  require_relative 'engines_osapi/service_actions.rb'
  include ServiceActions
  require_relative 'engines_osapi/service_configuration_actions.rb'
  include ServiceConfigurationActions
  require_relative 'engines_osapi/subservice_actions.rb'
  include SubserviceActions
  require_relative 'engines_osapi/system_control_actions.rb'
  include SystemControlActions
  require_relative 'engines_osapi/system_key_actions.rb'
  include SystemKeyActions
  require_relative 'engines_osapi/system_metrics.rb'
  include SystemMetrics
  require_relative 'engines_osapi/template_actions.rb'
  include TemplateActions
  require_relative 'engines_osapi/update_actions.rb'
  include UpdateActions
  require_relative 'engines_osapi/return_objects.rb'
  include ReturnObjects
  require 'objspace'
  attr_reader :core_api, :last_error
  def shutdown(why)

    p :SYSTEM_SHUTDOWN_VIA
    p why

  end

  require_relative 'engines_osapi/engines_api_version.rb'
  include EngOSapiVersion

  def initialize
    ObjectSpace.trace_object_allocations_start
    @core_api = EnginesCore.new
  end

  def reserved_engine_names
    names = list_apps
    names.concat(list_services)
    names.concat(list_system_services)
  end

  def reserved_hostnames
    @core_api.taken_hostnames
  end

  def set_first_run_parameters(params_from_gui)
    params = params_from_gui.dup
    p params
    first_run = FirstRunWizard.new(params)
    first_run.apply(@core_api)
    return success('Gui', 'First Run') if first_run.sucess
    failed('Gui', 'First Run', first_run.error.to_s)
  rescue StandardError => e
    SystemUtils.log_exception(e)
    failed('Gui', 'First Run', 'failed')
  end

  def last_api_error
    return @core_api.last_error if @core_api
    return 'no Core!'
  rescue StandardError => e
    log_exception_and_fail('last_api_error', e)
  end

  # FIXME USED by Engines cmd line need to do differently in there so leave here for the moment
  def read_state(container)
    container.read_state
  rescue StandardError => e
    log_exception_and_fail('read_state', e)
  end

  #
  #  def list_services_for(object)
  #    return @core_api.list_services_for(object)
  #  end

  def get_managed_service_details_for(service_function) # WTF
    service = {}
    if service_function == 'http_router'
      service[:provider_namespace] = 'EnginesSystem'
      service[:type_path] = 'nginx'
    end
    service
  end

end
