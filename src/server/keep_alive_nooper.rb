class KeepAliveNooper 
  require 'timers'
  def initialize
    super()
    @timers = Timers::Group.new
end
def run(out)
  Thread.new do
    run_timer(out)
  end
  
end
def cancel
  @timers.cancel            
end
def run_timer(out)
  no_op = {no_op: true}.to_json
     
        @timers.every(25) do
         if out.closed?
           STDERR.puts('NOOP found OUT IS CLOSED: ' )      
           @timers.cancel                         
         else
           out << no_op # unless lock_timer == true
           STDERR.puts('NOOP ')
           out << "\n"
         end
        end 
  loop { timers.wait }        
end
  
end