class EventListener

  attr_accessor :container_name, :event_mask, :priority

  def initialize(object, method, event_mask, container_name = nil, priority = 200)
    @object = object
    @method = method
    @event_mask = event_mask
    @container_name = container_name
    @priority = priority
  end

  def hash_name
    @object.object_id.to_s
  end

  def trigger(hash)
    r = true
    mask = EventMask.event_mask(hash)
    #  SystemDebug.debug(SystemDebug.container_events, 'trigger  mask ' + mask.to_s + ' hash ' + hash.to_s + ' listeners mask:' + @event_mask.to_s + ' result ' )#+ (@event_mask & mask).to_s)
    unless @event_mask & mask == 0
      # skip top
      if mask & 32768 == 0 # @@container_top == 0
        hash[:state] = state_from_status(hash[:status])
        # SystemDebug.debug(SystemDebug.container_events, 'fired ' + @object.to_s + ' ' + @method.to_s + ' with ' + hash.to_s)
        begin
          STDERR.puts('firing ' + @object.to_s + ' ' + @method.to_s + ' with ' + hash.to_s)
          thr = Thread.new {@object.method(@method).call(hash)}
          thr.name = "#{@object}:#{@method}"
          r = true
        rescue EnginesException => e
          SystemDebug.debug(SystemDebug.container_events, e.to_s + ':' + e.backtrace.to_s)
          STDERR.puts(e.to_s + ":\n" + e.backtrace.to_s) if e.level == :error
          thr.exit()
          false
        rescue StandardError => e
          STDERR.puts('EXCPETION:' + e.to_s + ":\n" + e.backtrace.to_s)
        end
      end
    end
    r
  rescue StandardError => e
    STDERR.puts(e.to_s + ":\n" + e.backtrace.to_s)
    SystemDebug.debug(SystemDebug.container_events, e.to_s + ':' + e.backtrace.to_s)
    # raise e
    false
  end

  def state_from_status(status)
    case status
    when 'die', 'stop', 'exec'
      status = :stopped
    when 'run','start'
      status = :running
    when :pause
      status = :paused
    when :unpause
      status = :running
      when 'delete','destroy'
      status = :nocontainer
    end
    status
  end
end
