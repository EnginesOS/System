module SystemLogging
  attr_reader :debug, :level, :last_error


  def SystemUtils.log_output(object, level)
     if SystemUtils.level < level
       if level == 10
          STDERR.puts 'Error[' + Process.pid.to_s + ']:' + object.to_s
       else 
          puts 'Info[' + Process.pid.to_s + ']:' + object.to_s
       end
     end
     return false
   end

   # @Logs to passeenger std out the @msg followed by @object.to_s
   #Logs are written to apache/error.log
   # error mesg is truncated to 512 bytes
   # returns nothing
   def SystemUtils.log_error_mesg(msg, *objects)
   err = msg.to_s  + ':->:' + objects.to_s
     #SystemUtils.log_output( msg.to_s + ':->:' + objects.to_s ,10)
     return EnginesError.new(err.to_s,:error)
   end
 
   def SystemUtils.log_error(object)
     STDERR.puts('ERROR' + object.to_s ) 
     SystemUtils.log_output(object, 10)
    
   end

end