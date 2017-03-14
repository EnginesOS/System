require '/opt/engines/lib/ruby/system/engines_error.rb'
class EnginesRegistryError < EnginesError
   
    def initialize(error_hash)
      if error_hash.is_a?(Hash)
        message = error_hash[:error_mesg]
        type = error_hash[:error_type]
        @params = error_hash[:params]
      else
        message = hash.to_s
        type = :error
        @params = []
      end
      
    super(message, type)
        @sub_system = 'engines_registry'
       @registry_source = error_hash[:source]
      end

end
