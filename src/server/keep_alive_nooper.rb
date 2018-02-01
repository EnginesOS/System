class KeepAliveNooper 
  require 'timers'
  def initialize
    super()
    @no_op = {no_op: true}.to_json
    @timers = Timers::Group.new
    @run = true
end
def run(out)
  Thread.new do
    run_timer(out)
  end
  
end

def cancel
  #@timer.cancel
  @run = false            
end

def run_timer(out)  
  while @run == true
    send(out)
    sleep 25    
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
    out << "\n"
    rescue
      cancel
    end
  end  
end

end