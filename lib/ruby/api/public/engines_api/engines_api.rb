class EnginesApi
  
 #methods called by api sinatra server routes
  #containers/
  get_changed_containers
  
  #containers/engine
  loadManagedEngine
  get_resolved_engine_string
  
  set_container_network_properties
  set_engine_runtime_properties
  
  container_memory_stats
  get_container_network_metrics
  
  get_build_report
  reinstall_engine
  remove_engine
  
  list_engine_actionators
  get_engine_actionator
  perform_engine_action
  #containers/engine/service/non_persistent
  find_engine_service_hash
  force_register_attached_service
  force_reregister_attached_service
  force_deregister_attached_service
  #containers/engine/service/non_persistent
  find_engine_service_hash
  
  #containers/engine/services/non_persistent
  find_engine_service_hash
  list_non_persistent_services

  #containers/engine/services/persistent
  engine_persistent_services
  find_engine_service_hash
  
  #containers/engines

  build_engine
  getManagedEngines
  list_managed_engines

  #containers/service
  loadManagedService 
  
  get_resolved_engine_string
  get_resolved_service_hash
  
  remove_service
  
  set_container_network_properties
  set_container_runtime_properties
  
  get_container_network_metrics
  container_memory_stats
  
  update_service_configuration
  
  list_service_actionators
  get_service_actionator
  perform_service_action
  
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
  
  
  #container/services/service/consumers
  
  #containers/services
  getManagedServices
  list_managed_services
  get_services_states
  list_system_services
  
  
  #resistry
  get_managed_engine_tree
  get_configurations_tree
  managed_service_tree
  get_orphaned_services_tree
  get_shares_tree
  
  #service_manager
  
  #system/control
  restart_system
  shutdown
  system_update
  
  
  #system/keys
  generate_engines_user_ssh_key
  update_public_key
  get_public_key
  
  
  
  #system/builder
  
  
  #system/certs
  get_system_ca
  get_cert
  list_certs
  remove_cert
  upload_ssl_certificate
  
  #system/config
  get_default_domain
  set_default_domain
  get_default_site
  set_default_site
  set_hostname
  system_hostname
  enable_remote_exception_logging
  disable_remote_exception_logging
  SystemStatus.is_remote_exception_logging?
  
  #system/firsrun
  set_first_run_parameters
  
  #system/domain
  domain_name
  update_domain
  
  #system/domains
  add_domain
  remove_domain
  list_domains
  
  
  #system/metrics
  MemoryStatistics.get_system_memory_info
  SystemStatus.get_system_load_info
  MemoryStatistics.total_memory_statistics(@@core_api)
  get_disk_statistics
  
  
  #system/reserved
  reserved_ports
  taken_hostnames
  reserved_engine_names
  
  #system/status
  first_run_required?
  SystemStatus.system_status
  
  #system/template
  get_resolved_string
  
  #system/versions
  SystemStatus.get_engines_system_release
  api_version
  version_string
  system_version
  SystemUtils.get_os_release_data
  
  
  
  
  
  
  
  
end