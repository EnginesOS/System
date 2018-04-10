require '/opt/engines/lib/ruby/api/system/errors_api.rb'

require_relative 'engines_public_api_error.rb'

class PublicApi < ErrorsApi
  def initialize(core_api )
    @core_api = core_api
    @system_api = @core_api.system_api
    # @service_manager = core_api.service_manager
  end

  #methods called by api sinatra server routes
  require_relative 'containers/containers.rb'
  #containers/
  #get_changed_containers #ex
  include PublicApiContainers

  require_relative 'containers/service_hash.rb'
  #find_service_service_hash
  #find_service_service_hashes
  #retrieve_engine_service_hash
  #retrieve_engine_service_hashes
  include PublicApiContainersServiceHash

  require_relative 'containers/properties.rb'
  # set_container_network_properties #ex
  # set_container_runtime_properties #ex
  include PublicApiContainersProperties

  require_relative 'containers/metrics.rb'
  # container_memory_stats #ex
  # get_container_network_metrics #ex
  include PublicApiContainersMetrics

  require_relative 'containers/engines/engine.rb'
  #containers/engine
  #  loadManagedEngine   #vc engines system
  #  get_resolved_engine_string #ex
  #  get_build_report #ex
  #  reinstall_engine #ex
  include PublicApiEngine

  require_relative 'containers/engines/actionators.rb'
  #container/engines/actionators
  #list_engine_actionators#EX
  #get_engine_actionator#EX
  #perform_engine_action#EX
  include PublicApiEngineActionators

  #containers/engine/service(s)/non_persistent
  require_relative 'containers/non_persistent_services.rb'
  #force_register_attached_service  #ex
  #force_reregister_attached_service  #ex
  #force_deregister_attached_service  #ex
  #list_non_persistent_services
  include PublicApiContainersNonPersistentServices

  require_relative 'containers/persistent_services.rb'
  #list_persistent_services(engine)
  include PublicApiContainersPersistentServices

  require_relative 'containers/engines/engines.rb'
  #containers/engines
  #build_engine #ex bis
  #  getManagedEngines# es
  # list_managed_engines #  es
  # should not be remove_engine but delete_engine(params)
  include PublicApiEngines

  require_relative 'containers/services/sub_services.rb'
  # services_subservices(params)
  # update_subservice(params)
  # attach_subservice(params)
  # remove_subservice(params)
  # attached_subservice(params)
  # subservice_provided(params)
  # subservices_provided(params)
  include PublicApiSubServices

  require_relative 'containers/services/service.rb'
  #containers/service
  #  loadManagedService # es
  #  get_resolved_engine_string #EX
  #  get_resolved_service_hash # WRONG NAME
  #  remove_service
  #  update_service_configuration#EX
  include PublicApiService

  require_relative 'containers/services/actionators.rb'
  #container/services/actionators
  #list_service_actionators#EX
  #get_service_actionator#EX
  #perform_service_action#EX
  include PublicApiServiceActionators

  #container/services/services/persistent
  #engine_persistent_services

  #container/services/service/consumer(s)
  #calls service directly

  require_relative 'containers/services/services.rb'
  #containers/services
  #  getManagedServices
  #  list_managed_services
  #  get_services_states
  #  list_system_services
  include PublicApiServices

  require_relative 'registry/registry.rb'
  #resistry
  #  managed_engines_registry#ex
  #  service_configurations_registry#ex
  #  managed_services_registry#ex#ex
  #  orphaned_services_registry#ex
  #  shared_services_registry #ex
  include PublicApiRegistry

  #service_manager

  require_relative 'system/control/base_os.rb'
  #restart_system
  #shutdown
  #system_update
  include PublicApiSystemControlBaseOS

  require_relative 'system/control/engines_system.rb'
  #update_engines_system_software
  #restart_mgmt
  #recreate_mgmt
  include PublicApiSystemControlEnginesSystem

  require_relative 'system/control/registry.rb'
  #force_registry_restart
  include PublicApiSystemControlRegistry

  require_relative 'system/keys.rb'
  #system/keys
  #  generate_engines_user_ssh_key
  #  update_public_key
  #  get_public_key
  include PublicApiSystemKeys

  #system/builder

  require_relative 'system/certificates.rb'
  #system/certs #EX
  #  get_system_ca #EX
  #  get_cert #EX
  #  list_certs #EX
  #  remove_cert #EX
  #  upload_ssl_certificate #EX
  include PublicApiSystemCertificates

  require_relative 'builder/builder.rb'
  include PublicApiBuilder

  require_relative 'system/config.rb'
  #system/config #EX
  #  get_default_domain #EX
  #  set_default_domain #EX
  #  get_default_site #EX
  #  set_default_site #EX
  #  set_hostname #EX
  # system_hostname #EX
  #  enable_remote_exception_logging#EX
  #  disable_remote_exception_logging   #EX
  #  is_remote_exception_logging? #EX
  include PublicApiConfig

  require_relative 'system/first_run.rb'
  #system/firsrun
  # set_first_run_parameters ex
  include PublicApiSystemFirstRun

  #system/domain(s)
  require_relative 'system/domains.rb'
  #domain_name
  #update_domain
  #  add_domain #nex
  #  remove_domain #nex
  #  list_domains #nex
  include PublicApiSystemDomains

  #system/metrics
  require_relative 'system/metrics.rb'
  #  MemoryStatistics.get_system_memory_info
  #  SystemStatus.get_system_load_info
  #  MemoryStatistics.total_memory_statistics(engines_api)
  #  get_disk_statistics
  include PublicApiSystemMetrics

  require_relative 'system/reserved.rb'
  #system/reserved
  #  reserved_ports
  #  taken_hostnames
  #  reserved_engine_names
  include PublicApiSystemReserved

  require_relative 'system/status.rb'
  #system/status
  #  first_run_required? #x
  #  SystemStatus.system_status
  include PublicApiStatus

  require_relative 'system/templater'
  #system/template ex
  #get_resolved_string ex
  include PublicApiSystemTemplater

  require_relative 'system/versions.rb'
  #system/versions
  #  SystemStatus.get_engines_system_release
  #  api_version
  #  version_string
  #  system_version
  #  SystemUtils.get_os_release_data
  include PublicApiSystemVersions

  require_relative 'service_manager/public_api_service_definitions.rb'
  include PublicApiServiceDefinitions

  require_relative 'service_manager/public_api_available_services.rb'
  include PublicApiAvailableServices

  require_relative 'engines_public_api_errors.rb'
  include EnginesPublicApiErrors

  require_relative 'engine_api_events.rb'
  include EngineApiEvents

  require_relative 'service_manager/public_api_orphans.rb'
  include PublicApiOrphans

  require_relative 'service_manager/public_api_persistent_services.rb'
  include  PublicApiPersistentServices

  require_relative 'backup.rb'
  include  PublicApiBackup
  require_relative 'system/user_auth.rb'
  include UserAuth
  require_relative 'system/system_auth.rb'
  include SystemAuth 
  require_relative 'system/gui_prefs.rb'
  include GuiPrefs

end