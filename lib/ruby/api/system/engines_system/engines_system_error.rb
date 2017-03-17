require '/opt/engines/lib/ruby/system/engines_error.rb'

class EnginesSystemError < EnginesError
  def initialize(message, type )
    super
    @sub_system = 'engines_system'
  end
end
