require_relative 'store'
require_relative 'cache'
require_relative 'store_locking'

module Container
  class UtilityStore < Store
    class << self
      def instance
        @@utility_instance ||= self.new
      end
    end

    protected

    def file_name(name)
      "#{store_directory}/#{name}/config.yaml"
    end

    def model_class
      ManagedUtility
    end

    def container_type
      'utility'
    end
  end
end
