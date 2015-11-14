class SystemApi < ErrorsApi
  require "/opt/engines/lib/ruby/containers/container.rb"
  require "/opt/engines/lib/ruby/containers/managed_container.rb"
  require "/opt/engines/lib/ruby/containers/managed_engine.rb"
  require "/opt/engines/lib/ruby/containers/managed_service.rb"
  require "/opt/engines/lib/ruby/containers/system_service.rb"

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
  
  def initialize(api)
    @engines_api = api
    @engines_conf_cache = {}
  end  

  
  def free_docker_lib_space
    res =  SystemUtils.execute_command('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/free_docker_lib_space engines@172.17.42.1 /opt/engines/bin/free_docker_lib_space.sh') 
    # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
    return -1 if result[:result] != 0
         
       return result[:stdout].to_i
  end

 
 
def restart_mgmt
  res = Thread.new { system('ssh  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i /home/engines/.ssh/mgmt/restart_mgmt engines@172.17.42.1 /opt/engines/bin/restart_mgmt.sh') }
  # FIXME: check a status flag after sudo side post ssh run ie when we know it's definititly happenging
  return true if res.status == 'run'
  return false
end

 

  def api_shutdown
    File.delete(SystemConfig.BuildRunningParamsFile) if File.exist?(SystemConfig.BuildRunningParamsFile)
  end
end
