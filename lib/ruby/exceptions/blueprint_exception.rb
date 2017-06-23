class BluePrintException < EnginesException
  attr_reader :status
  def initialize( hash)
    @status = hash[:status] if hash.is_a?(Hash)
    STDERR.puts('BluePrintException ') unless @level == :warning 
    super(hash)
  end
end