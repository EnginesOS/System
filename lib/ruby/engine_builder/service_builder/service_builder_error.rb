class ServiceBuilderError < EnginesError
  def initialize(message, type = :fail)
    super
    @sub_system = 'service_builder'
  end
end
