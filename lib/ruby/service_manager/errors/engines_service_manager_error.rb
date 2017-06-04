require '/opt/engines/lib/ruby/system/engines_error.rb'

class EnginesServiceManagerError < EnginesError
  def initialize(message, type)
    super
    @sub_system = 'engines_service_manager'
  end
end
