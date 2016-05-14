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
  
  def initialize(api)
    @engines_api = api
    @engines_conf_cache = {}
    @docker_event_listener = start_docker_event_listener
    @docker_event_listener.add_event_listener([self,'container_event'.to_sym])
  end
  
  def list_system_services
  services = []
     services.push('registry')
     return services
  end
  
  def get_engines_states
    result = {}
    engines = getManagedEngines #list_managed_engines
    engines.each do |engine|
      result[engine.container_name.to_sym] = engine.read_state.to_sym
    end

    return result
  end
  
  def get_services_states
    result = {}
    services =  getManagedServices # list_managed_services
        services.each do |service|
          result[service.container_name.to_sym] = service.read_state.to_sym
        end

        return result
   end

  def system_image_free_space
    result =  SystemUtils.execute_command('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/free_docker_lib_space engines@' + SystemStatus.get_management_ip + '  /opt/engines/bin/free_docker_lib_space.sh')
    return -1 if result[:result] != 0
    return result[:stdout].to_i
  rescue StandardError => e
    log_exception(e)
    return -1
  end

  def restart_mgmt
    res = Thread.new { system('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/restart_mgmt engines@' + SystemStatus.get_management_ip + '  /opt/engines/bin/restart_mgmt.sh') }
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    return true if res.status == 'run'
    return false
  end

  def api_shutdown(reason)
     log_error_mesg("Shutdown Due to:" + reason.to_s)
    File.delete(SystemConfig.BuildRunningParamsFile) if File.exist?(SystemConfig.BuildRunningParamsFile)
    res = Thread.new { system('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/halt_system engines@' + SystemStatus.get_management_ip + '  /opt/engines/bin/halt_system.sh') }
  end
end
