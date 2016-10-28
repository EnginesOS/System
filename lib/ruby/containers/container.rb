require '/opt/engines/lib/ruby/api/system/errors_api.rb'

class Container < ErrorsApi
  require_relative 'container/container_setup.rb'
  include ContainerSetup
  require_relative 'container/container_controls.rb'
  include ContainerControls
  require_relative 'container/docker_info_collector.rb'
  include DockerInfoCollector
  require_relative 'container/container_status.rb'
  include ContainerStatus
  require_relative 'container/image_controls.rb'
  include ImageControls
  require_relative 'container/running_container_statistics.rb'
  include RunningContainerStatistics
  require_relative 'container/engines_api_access.rb'
  include EnginesApiAccess
  @conf_register_dns = true
  def self.from_yaml(yaml, container_api)
    container = YAML::load(yaml)
    return SystemUtils.log_error_mesg(" Failed to Load yaml ", yaml) if container.nil?
    container.container_api = container_api
    container.post_load
    return container
  rescue Exception => e
    SystemUtils.log_error_mesg(" Failed to Load yaml " + e.to_s, yaml)
  end

  attr_reader :container_id,\
  :memory,\
  :container_name,\
  :image,\
  :web_port,\
  :volumes,\
  :mapped_ports,\
  :environments,\
  :setState

  attr_accessor :last_error,\
  :container_api,
  :last_result,
  :container_id,
  :arguments

  def update_memory(new_memory)
    @memory = new_memory
  end

  def on_host_net?
    return true if @host_network.is_a?(TrueClass)
    return false
  end

  def to_h

    self.instance_variables.each_with_object({}) do |var, hash|
      var.to_s.delete!("@")
      next if var.end_with?('_api')
      next if var.end_with?('docker_info_cache')
      next if var.end_with?('last_result')
      next if var.end_with?('mutex')
      hash[var.to_sym] = self.instance_variable_get(var)
    end

  end

  def encode_with(coder)
    vars = instance_variables.map{|x| x.to_s}
    vars = vars - ['@docker_info_cache', '@last_result','@container_api','@container_mutex']

    vars.each do |var|
      var_val = eval(var)
      coder[var.gsub('@', '')] = var_val
    end
  end

end

