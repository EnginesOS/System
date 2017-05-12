class SystemApi < ErrorsApi
  

  require '/opt/engines/lib/ruby/api/system/system_preferences.rb'
  require '/opt/engines/lib/ruby/containers/container.rb'
  require '/opt/engines/lib/ruby/containers/managed_container.rb'
  require '/opt/engines/lib/ruby/containers/managed_engine.rb'
  require '/opt/engines/lib/ruby/containers/managed_service.rb'
  require '/opt/engines/lib/ruby/containers/system_service/system_service.rb'
  require '/opt/engines/lib/ruby/system/system_config.rb'
  require '/opt/engines/lib/ruby/system/engines_error.rb'
  #  require_relative 'engines_system_error.rb'
  #  require_relative 'engines_system_errors.rb'
  #  include EnginesSystemErrors

  require_relative 'system_host/base_os_system.rb'
  include BaseOsSystem
  
  require_relative 'system_host/engines_server_host.rb'
  include EnginesServerHost
  
  require_relative 'system_host/engines_system_update.rb'
  include EnginesSystemUpdate
  
  require_relative 'system_host/system_settings.rb'
  include SystemSettings
  
  require_relative 'system_host/ssh_keys.rb'
  include SshKeys
  
  require_relative 'managed_containers/managed_container_status.rb'
  include ManagedContainerStatus
 
  require_relative 'managed_containers/cache.rb'
  include Cache
    
  require_relative 'managed_containers/container_state_files.rb'
  include ContainerSystemStateFiles
  
  require_relative 'managed_containers/containers'
  include Containers
  
  require_relative 'managed_containers/engines.rb'
  include Engines
  
  require_relative 'managed_containers/services.rb'
  include Services
  
  require_relative 'managed_containers/container_locking.rb'
  include ContainerLocking
  
  require_relative 'managed_containers/container_network_metrics.rb'
  include  ContainerNetworkMetrics
  
  require_relative 'managed_containers/container_change_monitor.rb'
  include ContainerChangeMonitor
  
  require_relative 'managed_containers/container_checks.rb'
  include ContainerChecks
  
  require_relative 'managed_containers/container_schedules.rb'
  include ContainerSchedules
  
  require_relative 'managed_containers/managed_utilities.rb'
  include ManagedUtilities
  
  
  require_relative 'build_report.rb'
  include BuildReport

  require_relative 'certificates.rb'
  include Certificates

  require_relative 'docker_events.rb'
  include DockerEvents

  require_relative 'service_management.rb'
  include ServiceManagement
  
  

  # FixMe
  # Put if first run needed around this
  require_relative 'first_run_complete.rb'
  include FirstRunComplete
  require_relative 'system_api_backup.rb'
  include SystemApiBackup

  def initialize(api)
    @engines_api = api
    @engines_conf_cache = {}
   
    create_event_listener unless $PROGRAM_NAME.end_with?('system_service.rb')
  end


  def list_system_services
    @system_services ||= ['system', 'registry']
  end

  
end
