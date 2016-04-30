class EnginesCoreError < EnginesError
  def initialize(message, type = :fail)
        super
        @source = caller[1].to_s 
        @sub_system = 'engines_core'
      end
end
