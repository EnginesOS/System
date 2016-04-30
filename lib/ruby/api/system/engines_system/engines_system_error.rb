class EnginesSystemError < EnginesError
  def initialize(message, type = :fail)
        super
        @source = caller[1].to_s 
        @sub_system = 'engines_system'
      end
end
