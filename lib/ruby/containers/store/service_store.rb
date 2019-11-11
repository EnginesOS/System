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

    def container_service_dir(sn)
      "#{SystemConfig.RunDir}/services/#{sn}"
    end

    def container_disabled_service_dir(sn)
      "#{SystemConfig.RunDir}/services-disabled/#{sn}"
    end

    protected

    def model_class
      ManagedService
    end

    def container_type
      'service'
    end
  end
end
