class EnginesError < FalseClass
  attr_accessor :source, :error_type, :error_mesg, :sub_system

  def initialize(message, type = :fail)
    @error_mesg = message
    @error_type = type
    @source = caller[1].to_s 
    @sub_system = 'global'
  end
end

