class EnginesError # < FalseClass
  attr_accessor :source, :error_type, :error_mesg, :sub_system

  def initialize(message, type )
    @error_mesg = message
    @error_type = type
    @source = caller[1].to_s 
    @sub_system = 'global'
  end
  
  def to_json(opt)
    p opt
    '{"error_type":"' + @error_type + '","error_mesg":"' + @error_mesg + '","sub_system":"' + @sub_system + '","source":"' + @source + '"}'
end
end

