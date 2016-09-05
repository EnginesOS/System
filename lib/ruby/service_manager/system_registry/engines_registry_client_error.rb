require '/opt/engines/lib/ruby/system/engines_error.rb'
class EnginesRegistryClientError < EnginesError
 
  def initialize(message, type, *objs )
    super(message, type)
    @params = *objs
        @sub_system = 'engines_registry_client'
      end
      
#  def to_json(opt)
#  #FixMe this is a kludge
#      '{"error_type":"' + @error_type.to_s + '","error_mesg":"' + @error_mesg.to_s + '","sub_system":"' + @sub_system.to_s + '","source":' + @source.to_s + ',"params":"' + @params.to_s + '"}'
#  end
  
 
end
