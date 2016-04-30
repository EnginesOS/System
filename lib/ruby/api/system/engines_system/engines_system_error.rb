require '/opt/engines/lib/ruby/system/engines_error.rb'
class EnginesSystemError #< EnginesError
 
  def initialize(message, type = :fail)
    @error_mesg = message
      @error_type = type
        @source = caller[1].to_s 
        @sub_system = 'engines_system'
      end
end
