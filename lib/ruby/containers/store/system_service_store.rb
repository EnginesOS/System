require_relative 'store'
require_relative 'cache'
require_relative 'store_locking'

module Container
  class SystemServiceStore < Store
    class << self
      def instance
        @@system_service_instance ||= self.new
      end
    end

    def file(name)
      unless File.exist?(file_name(name))
        resolve_running_config(name)
      end
      super
    end

    protected

    def resolve_running_config(name)
      #should not build dir from parts but use appropriate method but which store issue needs to be fixed
      service_type_dir = "#{SystemConfig.RunDir}/#{container_type}s"
      config_template_file_name = "#{service_type_dir}/#{name}/config.yaml"
      if File.exist?(config_template_file_name)
        config_template = File.read(config_template_file_name)
        templator = Templater.new(nil)
        running_config = templator.process_templated_string(config_template)
        yam1_file_name = "#{service_type_dir}/#{name}/running.yaml"
        yaml_file = File.new(yam1_file_name, 'w+')
        begin
          yaml_file.write(running_config)
        ensure
          yaml_file.close
        end
      else
        SystemUtils.log_error_mesg('Running exist', service_name)
        raise EnginesException.new(error_hash('failed to create service file ', SystemConfig.RunDir + service_type_dir + '/' + service_name.to_s))
      end
    end

    def model_class
      SystemService
    end

    def container_type
      'system_service'
    end
  end
end
