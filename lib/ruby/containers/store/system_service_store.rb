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

    def file_name(name)
      #Fixme only do for missing as in via when exception but without breaking recovery of running.bak
      f = super
      unless File.exist?(f)
        resolve_running_config(f)
      else
        f
      end
    end

    protected

    def resolve_running_config(name)
      name.gsub!(/\/running.yaml/,'')
      #should not build dir from parts but use appropriate method but which store issue needs to be fixed
      config_template_file_name = "#{name}/config.yaml"
      if File.exist?(config_template_file_name)
        config_template = File.read(config_template_file_name)
        templator = Templater.new(nil)
        running_config = templator.process_templated_string(config_template)
        yam1_file_name = "#{name}/running.yaml"
        begin
          yaml_file = File.new(yam1_file_name, 'w+')
          yaml_file.write(running_config)
        ensure
          yaml_file.close unless yaml_file.nil?
        end
        yam1_file_name
      else
        SystemUtils.log_error_mesg('no config_template_file_name exist', name)
        nil
      end
      yam1_file_name
    end

    def model_class
      SystemService
    end

    def container_type
      'system_service'
    end
  end
end
