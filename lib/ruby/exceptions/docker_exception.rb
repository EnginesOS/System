class DockerException < EnginesException
  attr_reader :status
  def initialize(hash)
    super(hash)
    STDERR.puts("Docker exeception:  #{hash}")
    begin
      @status = hash[:status] 
      @module = :docker
     STDERR.puts("Docker exeception Body:  #{hash[:body]}")
      @error_mesg = hash[:body][:message]
    STDERR.puts("Docker exeception:  #{error_mesg}")
    rescue StandardError => e
      STDERR.puts(" EX #{e} #{e.backtrace}")
    end
    SystemDebug.debug(SystemDebug.docker, 'Docker Exception', hash.to_s) unless @status == 404
    hash[:error_type] = :warning if @status == 404
  STDERR.puts("Docker exeception:  #{self}")
  end
  
  def to_s
    "#{self.to_h}"
  end
end
