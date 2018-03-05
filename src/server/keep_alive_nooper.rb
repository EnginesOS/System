class KeepAliveNooper 
  require 'timers'
  def initialize
    super()
    @no_op = {no_op: true}.to_json
    @timers = Timers::Group.new
    @run = true
    @cr = "\n"
   
end
def run(out)
  @timer_thread = Thread.new do
    run_timer(out)
    STDERR.puts('NEW NOOPALOOPER Thread')
  end
  @timer_thread[:name] = 'noop looper'  
end

def cancel
  #@timer.cancel
  @run = false  
  @timer_thread.exit unless @timer_thread.nil?     
end

def run_timer(out)  
  while @run == true
    send(out)
    sleep 25   
    STDERR.puts('SLEEP 25 ')
  end
# @timer = @timers.every(25) { send(out) }      
#  loop { timers.wait }        
end
  
def send(out)
  if out.closed?
    cancel
  else  
    begin
    out << @no_op
    out << @cr
    rescue
      cancel
    end
  end  
end

end