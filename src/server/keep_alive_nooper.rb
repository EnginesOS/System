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
    run_timer(out)
end

def cancel
  @timer.cancel
  @run = false    
end

def run_timer(out)  
 @timer = @timers.every(25) { send(out) }      
  loop { @timers.wait }        
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