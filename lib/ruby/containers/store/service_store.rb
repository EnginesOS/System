require_relative 'system_service_store'
require_relative 'cache'
require_relative 'store_locking'

module Container
  class ServiceStore < SystemServiceStore
    class << self
      def instance
        @@service_instance ||= self.new
      end
    end

    def all_names
      Dir.entries(store_directory).map do |d|
        d if file_exists?("#{d}/config.yaml")          
      end.compact
    end
    
    protected

    def file_name(name)
      File.exist?(super) ? super : config_file_name(name)
    end

    def config_file_name(name)
      #Kludge
      STDERR.puts("CAlling Kludge  #{name} in #{store_directory}")
      ContainerStateFiles.build_running_service(name, store_directory)
     "#{store_directory}/#{name}/running.yaml"
      #was beloew but that broke templates
     # "#{store_directory}/#{name}/config.yaml"
    end
    
    def model_class
      ManagedService
    end

    def container_type
      'service'
    end
  end
end
