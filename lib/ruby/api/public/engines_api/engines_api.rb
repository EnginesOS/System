require '/opt/engines/lib/ruby/api/system/errors_api.rb'
class EnginesApi < ErrorsApi
  
  def initialize(core_api , system_api)
    
    @core_api = core_api
    @system_api = system_api
    @service_manager = core_api.service_manager
    
  end
 #methods called by api sinatra server routes
  require_relative 'containers/containers.rb'
  #containers/
  #get_changed_containers #ex
  include Containers
  
  #containers/engine
  loadManagedEngine   #vc engines system
  get_resolved_engine_string #ex
  
  set_container_network_properties #ex
  set_engine_runtime_properties #ex
  
  container_memory_stats #ex
  get_container_network_metrics #ex
  
  get_build_report #ex
  reinstall_engine #ex
  remove_engine #ex
  
  list_engine_actionators #ex
  get_engine_actionator #ex
  perform_engine_action #ex
  #containers/engine/service/non_persistent
  find_engine_service_hash #vc sm
  force_register_attached_service  #ex 
  force_reregister_attached_service  #ex 
  force_deregister_attached_service  #ex
  #containers/engine/service/non_persistent
  find_engine_service_hash#vc sm
  
  #containers/engine/services/non_persistent
  find_engine_service_hash#vc sm
  list_non_persistent_services #ex sm

  #containers/engine/services/persistent
  engine_persistent_services #vc ec
  find_engine_service_hash #vc sm
  
  require_relative 'containers/engines/engines.rb'
  #containers/engines
  #build_engine #ex bis
#  getManagedEngines# es
 # list_managed_engines #  es
  include Engines
  
  

  #containers/service
  loadManagedService # es
  
  get_resolved_engine_string #EX
  get_resolved_service_hash # WRONG NAME
  
  remove_service
  
  set_container_network_properties#EX
  set_container_runtime_properties#EX
  
  get_container_network_metrics#EX
  container_memory_stats#EX
  
  update_service_configuration#EX
  
  list_service_actionators#EX
  get_service_actionator#EX
  perform_service_action#EX
  
  #container/services/services/persistent  
  engine_persistent_services
  find_engine_service_hash
  
  #container/services/services/non_persistent
  list_non_persistent_services
  find_engine_service_hash
  
  #container/services/service/persistent  
  find_engine_service_hash
  
  #container/services/service/non_persistent
  list_non_persistent_services
  find_engine_service_hash
  
  #container/services/service/consumer
  stuf
  
  #container/services/service/consumers
  stuf
  
  
  require_relative 'services/services.rb'
  #containers/services
#  getManagedServices
#  list_managed_services
#  get_services_states
#  list_system_services
  include Services
  
  
  require_relative 'registry/registry.rb'
  #resistry
#  get_managed_engine_tree#ex
#  get_configurations_tree#ex
#  managed_service_tree#ex#ex
#  get_orphaned_services_tree#ex
#  get_shares_tree #ex
  include Registry
  
  #service_manager
  
  require_relative 'system/control/base_os.rb'
  #restart_system
  #shutdown
  #system_update   
 include SystemControlBaseOS
 
  require_relative 'system/control/engines_system.rb'
   #update_engines_system_software
   #restart_mgmt
   #recreate_mgmt   
  include SystemControlEnginesSystem
  
  require_relative 'system/control/registry.rb'
  #force_registry_restart
    include SystemControlregistry
    
  
  require_relative 'system/keys.rb'
  #system/keys
#  generate_engines_user_ssh_key
#  update_public_key
#  get_public_key
  include SystemKeys
  
  
  
  
  #system/builder
  
  require_relative 'system/certificates.rb'
  #system/certs #EX
#  get_system_ca #EX
#  get_cert #EX
#  list_certs #EX
#  remove_cert #EX
#  upload_ssl_certificate #EX
  include 'SystemCertificates'
  
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
  include SystemConfig
  
  require_relative 'system/first_run.rb'
  #system/firsrun
 # set_first_run_parameters ex
  include SystemFirstRun
  

  
  #system/domain(s)
  require_relative 'system/domains.rb'
  #domain_name
    #update_domain
#  add_domain #nex
#  remove_domain #nex
#  list_domains #nex
  include SystemDomains
  
  #system/metrics
  require_relative 'system/metrics.rb'
#  MemoryStatistics.get_system_memory_info
#  SystemStatus.get_system_load_info
#  MemoryStatistics.total_memory_statistics(@@core_api)
#  get_disk_statistics
  include SystemMetrics
  
  require_relative 'system/reserved.rb'
  #system/reserved
#  reserved_ports
#  taken_hostnames
#  reserved_engine_names
  include SystemReserved
  
  require_relative 'system/system_status.rb'
  #system/status
#  first_run_required? #x
#  SystemStatus.system_status
  include SystemStatus
  
  
  require_relative 'system/templater'
  #system/template ex
  #get_resolved_string ex
  include SystemTemplater
  
  require_relative 'system/version.rb'
  #system/versions
#  SystemStatus.get_engines_system_release
#  api_version
#  version_string
#  system_version
#  SystemUtils.get_os_release_data
  include SystemVersions
  
 
end