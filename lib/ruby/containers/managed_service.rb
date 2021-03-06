#require '/opt/engines/lib/ruby/containers/ManagedContainer.rb'
#require 'objspace'
require '/opt/engines/lib/ruby/containers/container.rb'
require '/opt/engines/lib/ruby/containers/managed_container.rb'

module Container
  class ManagedService < ManagedContainer
    require_relative 'managed_service/managed_service_api.rb'
    include ManagedServiceApi
    require_relative 'managed_service/managed_service_configurations.rb'
    include ManagedServiceConfigurations
    require_relative 'managed_service/managed_service_consumers.rb'
    include ManagedServiceConsumers
    require_relative 'managed_service/managed_service_readers.rb'
    include ManagedServiceReaders
    require_relative 'managed_service/managed_service_container_info.rb'
    include ManagedServiceContainerInfo
    require_relative 'managed_service/managed_service_controls.rb'
    include ManagedServiceControls
    require_relative 'managed_service/managed_service_image_controls.rb'
    include ManagedServiceImageControls
    require_relative 'managed_service/managed_service_on_action.rb'
    include ManagedServiceOnAction
    require_relative 'managed_service/managed_service_import_export.rb'
    include ManagedServiceImportExport

    @ctype='service'
    @soft_service = false

    def lock_values
      super
      @ctype = 'service' if @ctype.nil?
      @ctype.freeze
    end

    def ctype
      @ctype
    end

    def is_soft_service?
      if @soft_service.is_a?(TrueClass)
        true
      else
        false
      end
    end

    attr_reader :persistent, :type_path, :publisher_namespace

    def to_service_hash()
      { :publisher_namespace => @publisher_namespace,
        :type_path => @type_path
      }
    end

    def destroy
      raise EnginesException.new(error_hash('Cannot call destroy on a service', container_name))
    end

    def error_type_hash(mesg, params = nil)
      {error_mesg: mesg,
        system: :managed_service,
        params: params }
    end

    #Sets @last_error to msg + object.to_s (truncated to 256 chars)
    #Calls SystemUtils.log_error_msg(msg,object) to log the error
    # @return none
    def self.log_error_mesg(msg, object)
      obj_str = object.to_s.slice(0, 512)
      SystemUtils.log_error_mesg(msg, object)
    end

    protected

    def container_api
      @container_api ||= ServiceApi.instance
    end
  end
end
