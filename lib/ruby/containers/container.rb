require '/opt/engines/lib/ruby/api/system/errors_api.rb'
require '/opt/engines/lib/ruby/api/system/container_state_files.rb'

module Container
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
    def self.from_yaml(yaml)
      container = YAML::load(yaml)
      raise EnginesException.new(error_hash('Failed to Load yaml_' + @container_name.to_s + '_ nil', yaml[0..256])) if container.nil?
      raise EnginesException.new(error_hash('Failed to Load yaml_' + @container_name.to_s + '_ false', yaml[0..256])) if container.is_a?(FalseClass)
      container.post_load
      container
    rescue StandardError => e
      STDERR.puts('Problem ' + e.to_s)
      STDERR.puts('With: ' + yaml.to_s)
      raise e
    end

    attr_reader   :memory,
    :container_name,
    :image,
    :web_port,
    :volumes,
    :mapped_ports,
    :environments,
    :set_state

    attr_accessor :last_error,
    :last_result,
    :arguments


def error_hash(mesg, params = nil)
   r = error_type_hash(mesg, params)
   r[:error_type] = :error
   r
 end
 
    def update_memory(new_memory)
      @memory = new_memory
    end

    def on_host_net?
      if @host_network.is_a?(TrueClass)
        true
      else
        false
      end
    end

    def stop_timeout
      @stop_timeout ||= 25
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
      vars = vars - ['@docker_info_cache', '@last_result','@container_api','container_mutex']

      vars.each do |var|
        var_val = eval(var)
        coder[var.gsub('@', '')] = var_val
      end
    end

    def error_hash(mesg, params = nil)
      r = error_type_hash(mesg, params)
      r[:error_type] = :error
      r
    end

    def warning_hash(mesg, params = nil)
      r = error_type_hash(mesg, params)
      r[:error_type] = :warning
      r
    end

    def error_type_hash(mesg, params = nil)
      {error_mesg: mesg,
        system: :container,
        params: params }
    end

    protected

    def container_api
      @container_api ||= ContainerApi.instance
    end
  end
end
