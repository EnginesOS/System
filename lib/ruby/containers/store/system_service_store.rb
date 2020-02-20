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

    protected

    def file_exists?(name)
      super || File.exist?(config_file_name(name))
    end

    def file_name(name)
      File.exist?(super) ? super : config_file_name(name)
    end

    def config_file_name(name)
      #Kludge
      STDERR.puts("CAlling Kludge  #{name} in #{store_directory}")
      ContainerStateFiles.build_running_service(name, store_directory)
     "{store_directory}/#{name}/running.yaml"
      #was beloew but that broke templates
     # "#{store_directory}/#{name}/config.yaml"
    end

    def model_class
      SystemService
    end

    def container_type
      'system_service'
    end
  end
end
