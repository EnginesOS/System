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
 
  
 
 
   #@Logs to passeenger std out the @msg followed by @object.to_s
   #Logs are written to apache/error.log
   # error mesg is truncated to 512 bytes
   # returns nothing
   def SystemUtils.log_error_mesg(msg, *objects)
     obj_str= ''
     objects.each do |object|     
        obj_str += object.to_s.slice(0, 512) + ':#:'
     end
     SystemUtils.log_output( msg.to_s + ':->:' + obj_str ,10)
     return EnginesError.new(msg.to_s,:error)
   end
 
   def SystemUtils.log_error(object)
     SystemUtils.log_output(object, 10)
    
   end

end