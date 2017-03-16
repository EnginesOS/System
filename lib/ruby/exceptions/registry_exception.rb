class EnginesException < StandardError
  attr_reader :status
  def initialize( hash)
    @status = hash[:status] if hash.is_a?(Hash)
    super(hash)
  end
end