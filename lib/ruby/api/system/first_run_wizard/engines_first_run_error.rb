require '/opt/engines/lib/ruby/system/engines_error.rb'

class EnginesFirstRunError < EnginesError
  def initialize(message, type )
    super
    @sub_system = 'first_run'
  end
end
