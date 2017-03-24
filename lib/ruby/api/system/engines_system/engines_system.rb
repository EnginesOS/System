class SystemApi < ErrorsApi
  require "/opt/engines/lib/ruby/containers/container.rb"
  require "/opt/engines/lib/ruby/containers/managed_container.rb"
  require "/opt/engines/lib/ruby/containers/managed_engine.rb"
  require "/opt/engines/lib/ruby/containers/managed_service.rb"
  require "/opt/engines/lib/ruby/containers/system_service.rb"

  require '/opt/engines/lib/ruby/system/engines_error.rb'
#  require_relative 'engines_system_error.rb'
#  require_relative 'engines_system_errors.rb'
#  include EnginesSystemErrors

  require_relative 'base_os_system.rb'
  include BaseOsSystem
  require_relative 'build_report.rb'
  include BuildReport
  require_relative 'cache.rb'
  include Cache
  require_relative 'certificates.rb'
  include Certificates
  require_relative 'containers'
  include Containers
  require_relative 'engines_system_update.rb'
  include EnginesSystemUpdate
  require_relative 'engines.rb'
  include Engines
  require_relative 'services.rb'
  include Services
  require_relative 'ssh_keys.rb'
  include SshKeys
  require_relative 'system_settings.rb'
  include SystemSettings
  require_relative 'container_locking.rb'
  include ContainerLocking
  require_relative 'docker_events.rb'
  include DockerEvents
  require_relative 'container_network_metrics.rb'
  include  ContainerNetworkMetrics
  require_relative 'container_change_monitor.rb'
  include ContainerChangeMonitor
  require_relative 'container_checks.rb'
  include ContainerChecks
  require_relative 'container_schedules.rb'
  include ContainerSchedules

  require_relative 'engines_server_host.rb'
  include EnginesServerHost

  require_relative 'service_management.rb'
  include ServiceManagement
  require_relative 'managed_utilities.rb'
  include ManagedUtilities
  # FixMe
  # Put if first run needed around this
  require_relative 'first_run_complete.rb'
  include FirstRunComplete
  require_relative 'system_api_backup.rb'
  include SystemApiBackup

  def initialize(api)
    @engines_api = api
    @engines_conf_cache = {}
    create_event_listener
  end

  def create_event_listener
    @event_listener_lock = true
    @docker_event_listener = start_docker_event_listener
    @docker_event_listener.add_event_listener([self,'container_event'.to_sym],16)
  end

  def list_system_services
    @system_services ||= ['system', 'registry']
  end

  def get_engines_states
    result = {}
    engines = getManagedEngines #list_managed_engines
    engines.each do |engine|
      begin
        result[engine.container_name] = engine.read_state
      rescue #skip services down
      end
    end
    result
  end

  def get_engines_status
    result = {}
    engines =  getManagedEngines # list_managed_services
    engines.each do |engine|
      begin
        result[engine.container_name] = engine.status
      rescue #skip services down
      end
    end
    result
  end

  def get_services_status
    result = {}
    services =  getManagedServices # list_managed_services
    services.each do |service|
      begin
        result[service.container_name] = service.status
      rescue #skip services down
      end
    end
    return result
  end

  def get_services_states
    services =  getManagedServices # list_managed_services
    result = {}
    services.each do |service|
      begin
        result[service.container_name] = service.read_state
      rescue DockerException
        next
      end
    end
    result
  end
end
