class KeepAliveNooper 
  require 'timers'
  def initialize
    super()
    @no_op = {no_op: true}.to_json
    @timers = Timers::Group.new
end
def run(out)
  Thread.new do
    run_timer(out)
  end
  
end

def cancel
  @timer.cancel            
end

def run_timer(out)  
  send(out)
 @timer = @timers.every(25) { send(out) }      
  loop { timers.wait }        
end
  
def send(out)
  if out.closed?
    cancel
  else  
    out << @no_op
    out << "\n"
  end  
end

end