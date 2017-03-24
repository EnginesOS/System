require '/opt/engines/lib/ruby/system/engines_error.rb'

class EngineApiError < EnginesError
  def initialize(message, type )
    super
    @sub_system = 'engine_api'
  end
end
