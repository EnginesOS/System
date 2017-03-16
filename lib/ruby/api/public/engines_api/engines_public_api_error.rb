class EnginesPublicApiError < EnginesError
  def initialize(message, type = :fail)
    super
    @sub_system = 'engine_public_api'
  end

end

