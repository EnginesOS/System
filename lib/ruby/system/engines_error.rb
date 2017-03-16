class EnginesError # < FalseClass
  require '/opt/engines/lib/ruby/exceptions/engines_exception.rb'
  attr_accessor :source, :error_type, :error_mesg, :sub_system

  def initialize(message, type, system = 'global')
    if message.is_a?(Hash)
      message = message.to_json
    end
      
    @error_mesg = message
    @error_type = type
    @sub_system = system
    @source = []
    @source[0] = caller[2].to_s 
    @source[1] = caller[3].to_s if caller.count >= 4
    @source[2] = caller[4].to_s if caller.count >= 5
    @source[3] = caller[4].to_s if caller.count >= 5
  end
  
def to_h
  
   self.instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete("@")] = self.instance_variable_get(var) }
    
end

def to_s
  @sub_system.to_s + ':' +  @error_type.to_s + ':'  + @error_mesg.to_s + ':' + @source.to_s
end
  def to_json(opt=nil)
  return self.to_h.to_json(opt)
end
end

