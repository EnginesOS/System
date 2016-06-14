class SystemApi < ErrorsApi
  require "/opt/engines/lib/ruby/containers/container.rb"
  require "/opt/engines/lib/ruby/containers/managed_container.rb"
  require "/opt/engines/lib/ruby/containers/managed_engine.rb"
  require "/opt/engines/lib/ruby/containers/managed_service.rb"
  require "/opt/engines/lib/ruby/containers/system_service.rb"
  
  require '/opt/engines/lib/ruby/system/engines_error.rb'
  require_relative 'engines_system_error.rb'
  require_relative 'engines_system_errors.rb'
  include EnginesSystemErrors
  
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
  
  require_relative 'engines_server_host.rb'
  include EnginesServerHost
  
  @@server_script_timeout = 10
  
  def initialize(api)
    @engines_api = api
    @engines_conf_cache = {}
    @docker_event_listener = start_docker_event_listener
    @docker_event_listener.add_event_listener([self,'container_event'.to_sym],16)
  end
  
  def list_system_services
  services = []
    services.push('system')
     services.push('registry')
     return services
  end
  
  def get_engines_states
    result = {}
    engines = getManagedEngines #list_managed_engines
    engines.each do |engine|
      result[engine.container_name] = engine.read_state
    end

    return result
  end
  
def get_engines_status
  result = {}
  engines =  getManagedEngines # list_managed_services
  engines.each do |engine|
        result[engine.container_name] = engine.status
      end
      return result
 end
 
def get_services_status
  result = {}
  services =  getManagedServices # list_managed_services
      services.each do |service|
        result[service.container_name] = service.status
      end

      return result
 end
 
  def get_services_states
    result = {}
    services =  getManagedServices # list_managed_services
        services.each do |service|
          result[service.container_name] = service.read_state
        end

        return result
   end

  
end
