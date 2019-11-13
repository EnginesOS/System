require_relative 'store'
require_relative 'cache'
require_relative 'store_locking'

module Container
  class UtilityStore < SystemServiceStore
    class << self
      def instance
        @@utility_instance ||= self.new
      end
    end

    protected

    def model_class
      ManagedUtility
    end

    def container_type
      'utility'
    end
  end
end
