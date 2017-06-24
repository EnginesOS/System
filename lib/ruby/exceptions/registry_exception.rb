class RegistryException < EnginesException
  attr_reader :status
  def initialize( hash)
    @status = hash[:status] if hash.is_a?(Hash)
    STDERR.puts('RegistryException ' + hash.to_s) unless hash[:error_type] == 'warning' 
    super(hash)
  end
end