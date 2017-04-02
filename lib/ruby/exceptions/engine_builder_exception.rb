class EngineBuilderException < EnginesException
  attr_reader :error_log, :build_log
  def initialize(error_h)
    @error_log = error_h[:error_log]
    @build_log = error_h[:build_log]
    super(error_h)
  end
end