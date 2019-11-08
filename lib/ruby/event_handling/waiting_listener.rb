class WaitingListener
  def initialize(what, pipe, emask = 16)
    @what = what
    @pipe = pipe
    @mask = emask
  end

  def mask
    @mask
  end

  def read_event(event_hash)
    unless @pipe.closed? || @pipe.nil?
      if event_hash[:status] == @what
        @pipe << 'ok'
        @pipe.close
      end
    else
      raise DockerException.new({:level => :warning, :error_mesg => 'pipe closed'} )
    end
  end
end
