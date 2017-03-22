class EnginesPublicApiError < EnginesError
  def initialize(message, type = :fail)
    @sub_system = 'engine_public_api'
    super
  end
end

