class DockerException < EnginesException
  attr_reader :status
  def initialize(hash)
    STDERR.puts('Docker exeception:' + hash.to_s)
    @status = hash[:status] if hash.is_a?(Hash)   
    SystemDebug.debug(SystemDebug.docker, 'Docker Exception', hash.to_s) unless @status == 404
    hash[:error_type] = :warning if @status == 404
    super(hash)
  end
end
