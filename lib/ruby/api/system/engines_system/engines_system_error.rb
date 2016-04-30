require '/opt/engines/lib/ruby/system/engines_error.rb'
class EnginesSystemError < EnginesError
 
  def initialize(message, type = :fail)
        super
        @source = caller[1].to_s 
        @sub_system = 'engines_system'
      end
end
