require '/opt/engines/lib/ruby/api/system/system_preferences.rb'
require '/opt/engines/lib/ruby/containers/container.rb'
require '/opt/engines/lib/ruby/containers/managed_container.rb'
require '/opt/engines/lib/ruby/containers/managed_engine.rb'
require '/opt/engines/lib/ruby/containers/managed_service.rb'
require '/opt/engines/lib/ruby/containers/system_service/system_service.rb'
require '/opt/engines/lib/ruby/system/system_config.rb'
require '/opt/engines/lib/ruby/system/engines_error.rb'
require '/opt/engines/lib/ruby/api/system/engines_core/engines_core'

class SystemApi < ErrorsApi
  class << self
    def instance
      @@instance ||= self.new
    end
  end

  require_relative 'events/docker_events.rb'
 # include DockerEvents

  require_relative 'events/events_trigger.rb'
 # include EventsTrigger

  require_relative 'system_host/base_os_system.rb'
  #include BaseOsSystem

  require_relative 'system_host/engines_server_host.rb'
  #include EnginesServerHost

  require_relative 'system_host/engines_system_update.rb'
  #include EnginesSystemUpdate

  require_relative 'system_host/system_settings.rb'
  #include SystemSettings

  require_relative 'system_host/ssh_keys.rb'
 # include SshKeys

  require_relative 'managed_containers/managed_container_status.rb'
 # include ManagedContainerStatus

  require_relative 'managed_containers/container_state_files.rb'
  #include ContainerSystemStateFiles

  require_relative 'managed_containers/containers'
#  include Containers

  require_relative 'managed_containers/container_actionators.rb'
 # include ContainerActionators

  require_relative 'managed_containers/engines.rb'
#  include Engines

  require_relative 'managed_containers/services.rb'
 # include Services

 # require_relative 'managed_containers/container_locking.rb'
 # include ContainerLocking

  require_relative 'managed_containers/container_network_metrics.rb'
 # include  ContainerNetworkMetrics

  require_relative 'managed_containers/container_change_monitor.rb'
 # include ContainerChangeMonitor

  require_relative 'managed_containers/container_checks.rb'
 # include ContainerChecks

  require_relative 'managed_containers/container_schedules.rb'
#  include ContainerSchedules

  require_relative 'managed_containers/managed_utilities.rb'
 # include ManagedUtilities

  require_relative 'managed_containers/container_info_tree.rb'
 # include ContainerInfoTree

  require_relative 'build_report.rb'
 # include BuildReport

  require_relative 'certificates.rb'
 # include Certificates

  require_relative 'service_management.rb'
 # include ServiceManagement

  require_relative 'system_host/engines_volumes.rb'
  #include EnginesVolumes
  # FixMe
  # Put if first run needed around this
  require_relative 'first_run_complete.rb'
 # include FirstRunComplete

  require_relative 'system_api_backup.rb'
 # include SystemApiBackup

  require_relative 'engines_system_errors'
 # include EnginesSystemErrors

  def initialize
    @container_conf_locks = {}
    create_event_listener 
  end

  def list_system_services
    @system_services ||= ['system', 'registry']
  end

  protected

  def core
    @core ||= EnginesCore.instance
  end
end
