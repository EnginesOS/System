require '/opt/engines/lib/ruby/system/engines_error.rb'
class EnginesRegistryError < EnginesError
 
  
    def initialize(error_hash)
      if error_hash.is_a?(Hash)
        message = error_hash[:error_mesg]
        type = error_hash[:error_type]
        @params = error_hash[:params]
          p :MESS    
           p  message
      else
        message = hash.to_s
        type = :error
        objs = []
      end
      
    super(message, type, *objs )
        @sub_system = 'engines_registry'
        @registry_source = error_hash[:source]
      end
      
  def to_json(opt)
  #FixMe this is a kludge
      '{"error_type":"' + @error_type.to_s + '","error_mesg":"' + @error_mesg.to_s + '","sub_system":"' + @sub_system.to_s + '","source":"' + @source.to_s + '","params":"' + @params.to_s + '"}'
  end
  
 
end
