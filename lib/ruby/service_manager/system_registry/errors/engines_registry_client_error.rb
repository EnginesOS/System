require '/opt/engines/lib/ruby/system/engines_error.rb'

class EnginesRegistryClientError < EnginesError
  def initialize(message, type, *objs )
    super(message, type)
    @params = *objs
    @sub_system = 'engines_registry_client'
  end

end
