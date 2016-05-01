class EnginesError # < FalseClass
  attr_accessor :source, :error_type, :error_mesg, :sub_system

  def initialize(message, type )
    @error_mesg = message
    @error_type = type
    @sub_system = 'global'
    @source = []
    @source[0] = caller[3].to_s 
    @source[1] = caller[4].to_s if caller.count > 4

  end
  
  def to_json(opt)
#FixMe this is a kludge
    '{"error_type":"' + @error_type.to_s + '","error_mesg":"' + @error_mesg.to_s + '","sub_system":"' + @sub_system.to_s + '","source":"' + @source.to_s + '"}'
end
end

