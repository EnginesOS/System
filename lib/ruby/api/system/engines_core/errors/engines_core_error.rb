class EnginesCoreError < EnginesError
  def initialize(message, type = :fail)
    super
    @sub_system = 'engines_core'
  end
end
