class RegistryException < EnginesException
  attr_reader :status
  def initialize( hash)
    @status = hash[:status] if hash.is_a?(Hash)
    STDERR.puts('RegistryException ') unless  e.level == :warning 
    super(hash)
  end
end