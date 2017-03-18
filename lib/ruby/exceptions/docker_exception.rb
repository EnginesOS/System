class DockerException < EnginesException
  attr_reader :status
  def initialize(hash)
    SystemDebug.debug(SystemDebug.docker, 'Docker Exception', hash.to_s)
    @status = hash[:status] if hash.is_a?(Hash)
    super(hash)
  end
end
